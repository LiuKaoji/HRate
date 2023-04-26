//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2019/1/30
//
// 本类已发生多处修改 请参阅源码
import Foundation
import AVFoundation
import Accelerate

public class RealtimeAnalyzer {
    private var fftSize: Int
    private lazy var fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))
    
    public var frequencyBands: Int{
        get{
            max(SpectrumView.barNumbers + 20, 240)
        } // 由于这个是动态变化 不能写固定值
    }
    public var startFrequency: Float = 200 //起始频率
    public var endFrequency: Float = 15000 //截止频率
    
    private var _bands: [(lowerFrequency: Float, upperFrequency: Float)]?

    private var bands: [(lowerFrequency: Float, upperFrequency: Float)] {
        if let cachedBands = _bands, cachedBands.count == frequencyBands {
            return cachedBands
        }

        var newBands = [(lowerFrequency: Float, upperFrequency: Float)]()
        let n = log2(endFrequency/startFrequency) / Float(frequencyBands)
        var nextBand: (lowerFrequency: Float, upperFrequency: Float) = (startFrequency, 0)
        for i in 1...frequencyBands {
            let highFrequency = nextBand.lowerFrequency * powf(2, n)
            nextBand.upperFrequency = i == frequencyBands ? endFrequency : highFrequency
            newBands.append(nextBand)
            nextBand.lowerFrequency = highFrequency
        }
        _bands = newBands
        return newBands
    }

    
    private var spectrumBuffer = [[Float]]()
    public var spectrumSmooth: Float = 0.3 {
        didSet {
            spectrumSmooth = max(0.0, spectrumSmooth)
            spectrumSmooth = min(1.0, spectrumSmooth)
        }
    }

   public init(fftSize: Int) {
        self.fftSize = fftSize
    }
    
    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }

    public func analyse(with buffer: AVAudioPCMBuffer) -> [Float] {
        
        let channelsAmplitudes = fft(buffer)
        let aWeights = createFrequencyWeights()
       
        if spectrumBuffer.count == 0 {
            for _ in 0..<channelsAmplitudes.count {
                spectrumBuffer.append(Array<Float>(repeating: 0, count: bands.count))
            }
        }
        for (index, amplitudes) in channelsAmplitudes.enumerated() {
            let weightedAmplitudes = amplitudes.enumerated().map {(index, element) in
                return element * aWeights[index]
            }
            var spectrum = bands.map {
                findMaxAmplitude(for: $0, in: weightedAmplitudes, with: Float(buffer.format.sampleRate)  / Float(self.fftSize)) * 5
            }
            spectrum = highlightWaveform(spectrum: spectrum)

            let zipped = zip(spectrumBuffer[index], spectrum)
            spectrumBuffer[index] = zipped.map { $0.0 * spectrumSmooth + $0.1 * (1 - spectrumSmooth) }
        }

        // Check the number of channels and combine them accordingly.
        var combinedSpectrum: [Float] = []
        if channelsAmplitudes.count > 1 {
            combinedSpectrum = zip(spectrumBuffer[0], spectrumBuffer[1]).map { ($0.0 + $0.1) / 2 }
        } else {
            combinedSpectrum = spectrumBuffer[0]
        }

        return combinedSpectrum
    }


    private func fft(_ buffer: AVAudioPCMBuffer) -> [[Float]] {
        var amplitudes = [[Float]]()
        guard let floatChannelData = buffer.floatChannelData else { return amplitudes }
        
        //1：抽取buffer中的样本数据
        let channels: UnsafePointer<UnsafeMutablePointer<Float>> = floatChannelData
        let channelCount = Int(buffer.format.channelCount)
        let isInterleaved = buffer.format.isInterleaved
        
        var channelData: [UnsafeMutablePointer<Float>] = []
        
        if isInterleaved {
            // Deinterleave
            let interleavedData = UnsafeBufferPointer(start: floatChannelData[0], count: self.fftSize * channelCount)
            for i in 0..<channelCount {
                let channel = UnsafeMutablePointer<Float>.allocate(capacity: fftSize)
                stride(from: i, to: interleavedData.count, by: channelCount).enumerated().forEach { (index, value) in
                    channel[index] = interleavedData[value]
                }
                channelData.append(channel)
            }
        } else {
            for i in 0..<channelCount {
                channelData.append(floatChannelData[i])
            }
        }
        
        for i in 0..<channelCount {
            
            let channel = channels[i]
            //2: 加汉宁窗
            var window = [Float](repeating: 0, count: Int(fftSize))
            vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
            vDSP_vmul(channel, 1, window, 1, channel, 1, vDSP_Length(fftSize))
            
            //3: 将实数包装成FFT要求的复数fftInOut，既是输入也是输出
            let realp = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize / 2))
            let imagp = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize / 2))
            
            var fftInOut = DSPSplitComplex(realp: realp, imagp: imagp)
            channel.withMemoryRebound(to: DSPComplex.self, capacity: fftSize) { (typeConvertedTransferBuffer) -> Void in
                vDSP_ctoz(typeConvertedTransferBuffer, 2, &fftInOut, 1, vDSP_Length(fftSize / 2))
            }
            
            //4：执行FFT
            vDSP_fft_zrip(fftSetup!, &fftInOut, 1, vDSP_Length(round(log2(Double(fftSize)))), FFTDirection(FFT_FORWARD));
            
            //5：调整FFT结果，计算振幅
            fftInOut.imagp[0] = 0
            let fftNormFactor = Float(1.0 / (Float(fftSize)))
            vDSP_vsmul(fftInOut.realp, 1, [fftNormFactor], fftInOut.realp, 1, vDSP_Length(fftSize / 2));
            vDSP_vsmul(fftInOut.imagp, 1, [fftNormFactor], fftInOut.imagp, 1, vDSP_Length(fftSize / 2));
            var channelAmplitudes = [Float](repeating: 0.0, count: Int(fftSize / 2))
            vDSP_zvabs(&fftInOut, 1, &channelAmplitudes, 1, vDSP_Length(fftSize / 2));
            channelAmplitudes[0] = channelAmplitudes[0] / 2 //直流分量的振幅需要再除以2
            amplitudes.append(channelAmplitudes)
            
        }
        return amplitudes
    }
    
    private func findMaxAmplitude(for band:(lowerFrequency: Float, upperFrequency: Float), in amplitudes: [Float], with bandWidth: Float) -> Float {
        let startIndex = Int(round(band.lowerFrequency / bandWidth))
        let endIndex = min(Int(round(band.upperFrequency / bandWidth)), amplitudes.count - 1)
        return amplitudes[startIndex...endIndex].max()!
    }
    
//    private func createFrequencyWeights() -> [Float] {
//        let Δf = 44100.0 / Float(fftSize)
//        let bins = fftSize / 2
//        var f = (0..<bins).map { Float($0) * Δf}
//        f = f.map { $0 * $0 }
//
//        let c1 = powf(12194.217, 2.0)
//        let c2 = powf(20.598997, 2.0)
//        let c3 = powf(107.65265, 2.0)
//        let c4 = powf(737.86223, 2.0)
//
//        let num = f.map { c1 * $0 * $0 }
//        let den = f.map { ($0 + c2) * sqrtf(($0 + c3) * ($0 + c4)) * ($0 + c1) }
//        let weights = num.enumerated().map { (index, ele) in
//            return 1.2589 * ele / den[index]
//        }
//        return weights
//    }
    private func createFrequencyWeights() -> [Float] {
        let sampleRate = 44100.0
        let Δf = Float(sampleRate) / Float(fftSize)
        let bins = fftSize / 2
        var f = (0..<bins).map { Float($0) * Δf }
        f = f.map { $0 * $0 }

        let c1 = powf(12194.217, 2.0)
        let c2 = powf(20.598997, 2.0)
        let c3 = powf(107.65265, 2.0)
        let c4 = powf(737.86223, 2.0)

        let num = f.map { c1 * $0 * $0 }
        let den = f.map { ($0 + c2) * sqrtf(($0 + c3) * ($0 + c4)) * ($0 + c1) }
        let weights = num.enumerated().map { (index, ele) in
            return 1.2589 * ele / den[index]
        }
        return weights
    }

    //highlightWaveform(spectrum: [Float]) -> [Float]：
    //这个方法对频谱进行高亮处理，可以更加直观地展现频谱数据。
    //具体实现是对每个频段进行加权平均，使得越高频的频段权重越大。
    //同时，对起点和终点的数据点进行平滑处理，以保证频谱更加连续。
    private func highlightWaveform(spectrum: [Float]) -> [Float] {
        let endIndex = frequencyBands
        var averagedSpectrum = [Float]()
        let startPointSmooth = 10
        let endPointSmooth = 10 // 增加终点平滑系数
        
        for i in 0..<endIndex {
            let weightFactor = 1.0 + pow(Float(i) / Float(frequencyBands), 3.0) * 20.0
            let weightsSize = max(5, Int(weightFactor))
            let weights = Array(repeating: 1.0, count: weightsSize)
            
            let totalWeights = Float(weights.count)
            
            let halfWeightsSize = weightsSize / 2
            let windowStart = max(0, i - halfWeightsSize)
            let windowEnd = min(spectrum.count, i + halfWeightsSize)
            
            let zipped = zip(Array(spectrum[windowStart..<windowEnd]), weights)
            var averaged = zipped.map { $0.0 * Float($0.1) }.reduce(0, +) / totalWeights
            
            // 对起点前和终点前的数据点进行平滑处理
            if i < startPointSmooth {
                let factor = Float(i + 1) / Float(startPointSmooth + 1)
                averaged *= factor
            } else if i >= endIndex - endPointSmooth {
                let factor = Float(endIndex - i) / Float(endPointSmooth + 1)
                averaged *= factor * 7 // 增加终点权重系数
            }
            
            averagedSpectrum.append(averaged)
        }
        
        return averagedSpectrum
    }
}
