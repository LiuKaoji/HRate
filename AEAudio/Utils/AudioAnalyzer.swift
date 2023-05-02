//
//  AudioAnalyzer.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AVFoundation
import Accelerate

@objc public class AudioAnalyzer: NSObject {
    
    public static var drawBands: Int = 0 //用于描绘动画的频带数量
    private var fftSize: Int
    private let fftSetup: FFTSetup
    private let realp: UnsafeMutablePointer<Float>// 实数的指针
    private let imagp: UnsafeMutablePointer<Float>// 虚数的指针
    private var fftLength: vDSP_Length // FFT 长度
    public var startFrequency: Float = 80 //起始频率
    public var endFrequency: Float = 4000 //截止频率
    //人耳在音乐和人声频率范围上通常较为敏感。音乐和人声的频率范围通常在大约80赫兹（Hz）至4000赫兹（4千赫兹，kHz）之间。在这个范围内，人类对声音的感知特别敏锐。


    
    private var frequencyBands: Int {
        get{
            return AudioAnalyzer.drawBands
        }
    }
    
    private lazy var bands: [(lowerFrequency: Float, upperFrequency: Float)] = {
        var bands = [(lowerFrequency: Float, upperFrequency: Float)]()
        //1：根据起止频谱、频带数量确定增长的倍数：2^n
        let n = log2(endFrequency/startFrequency) / Float(frequencyBands)
        var nextBand: (lowerFrequency: Float, upperFrequency: Float) = (startFrequency, 0)
        for i in 1...frequencyBands {
            //2：频带的上频点是下频点的2^n倍
            let highFrequency = nextBand.lowerFrequency * powf(2, n)
            nextBand.upperFrequency = i == frequencyBands ? endFrequency : highFrequency
            bands.append(nextBand)
            nextBand.lowerFrequency = highFrequency
        }
        return bands
    }()
    
    private var spectrumBuffer = [[Float]]()
    public var spectrumSmooth: Float = 0.5 {
        didSet {
            spectrumSmooth = max(0.0, spectrumSmooth)
            spectrumSmooth = min(1.0, spectrumSmooth)
        }
    }
    
    init(fftSize: Int) {
        self.fftSize = fftSize
        realp = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize / 2))
        imagp = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize / 2))
        fftLength = vDSP_Length(round(log2(Double(fftSize))))
        fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))!
    }
    
    deinit {
        realp.deallocate()
        imagp.deallocate()
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    func analyse(with buffer: AVAudioPCMBuffer) -> [Float] {
        let channelAmplitudes = fft(buffer)
        //let aWeights = createFrequencyWeights()
        if spectrumBuffer.count == 0 {
            spectrumBuffer.append(Array<Float>(repeating: 0, count: bands.count))
        }
        
        let weightedAmplitudes = channelAmplitudes
        
        var spectrum = bands.map {
            findMaxAmplitude(for: $0, in: weightedAmplitudes, with: Float(buffer.format.sampleRate)  / Float(self.fftSize)) * 5
        }
        spectrum = highlightWaveform(spectrum: spectrum)
        
        spectrumBuffer[0] = zip(spectrumBuffer[0], spectrum).map { $0 * spectrumSmooth + $1 * (1 - spectrumSmooth) }
        
        
        return spectrumBuffer.first!
    }
    
    private func fft(_ buffer: AVAudioPCMBuffer) -> [Float] {
        var channelAmplitudes = [Float]()
        guard let floatChannelData = buffer.floatChannelData else { return channelAmplitudes }
        
        // 将声道设置为单声道，并获取单声道数据：
        let channelData = floatChannelData[0]
        
        //2: 加汉宁窗
        var window = [Float](repeating: 0, count: Int(fftSize))
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(channelData, 1, window, 1, channelData, 1, vDSP_Length(fftSize))
        
        //3: 将实数包装成FFT要求的复数fftInOut，既是输入也是输出
        var fftInOut = DSPSplitComplex(realp: realp, imagp: imagp)
        channelData.withMemoryRebound(to: DSPComplex.self, capacity: fftSize) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &fftInOut, 1, vDSP_Length(fftSize / 2))
        }
        
        //4：执行FFT
        vDSP_fft_zrip(fftSetup, &fftInOut, 1, fftLength, FFTDirection(FFT_FORWARD));
        
        //5：调整FFT结果，计算振幅
        fftInOut.imagp[0] = 0
        let fftNormFactor = Float(1.0 / (Float(fftSize)))
        vDSP_vsmul(fftInOut.realp, 1, [fftNormFactor], fftInOut.realp, 1, vDSP_Length(fftSize / 2));
        vDSP_vsmul(fftInOut.imagp, 1, [fftNormFactor], fftInOut.imagp, 1, vDSP_Length(fftSize / 2));
        channelAmplitudes = [Float](repeating: 0.0, count: Int(fftSize / 2))
        vDSP_zvabs(&fftInOut, 1, &channelAmplitudes, 1, vDSP_Length(fftSize / 2));
        channelAmplitudes[0] = channelAmplitudes[0] / 2 //直流分量的振幅需要再除以2
        
        return channelAmplitudes
    }
    
    private func findMaxAmplitude(for band:(lowerFrequency: Float, upperFrequency: Float), in amplitudes: [Float], with bandWidth: Float) -> Float {
        let startIndex = Int(round(band.lowerFrequency / bandWidth))
        let endIndex = min(Int(round(band.upperFrequency / bandWidth)), amplitudes.count - 1)
        return amplitudes[startIndex...endIndex].max()!
    }
    
    
    private func highlightWaveform(spectrum: [Float]) -> [Float] {
        let scaleFactor: Float = 0.5 // 缩放因子，可调整
        //1: 定义权重数组，数组中间的5表示自己的权重
        //   可以随意修改，个数需要奇数
        let weights: [Float] = [1, 3, 5, 7, 5, 3, 1]
        let totalWeights = Float(weights.reduce(0, +))
        let startIndex = weights.count / 2
        //2: 开头几个不参与计算
        var averagedSpectrum = Array(spectrum[0..<startIndex])
        for i in startIndex..<spectrum.count - startIndex {
            //3: zip作用: zip([a,b,c], [x,y,z]) -> [(a,x), (b,y), (c,z)]
            let zipped = zip(Array(spectrum[i - startIndex...i + startIndex]), weights)
            let averaged = zipped.reduce(0) { $0 + $1.0 * $1.1 } / totalWeights
            averagedSpectrum.append(averaged)
        }
        //4：末尾几个不参与计算
        averagedSpectrum.append(contentsOf: Array(spectrum.suffix(startIndex)))
        
        // 应用缩放因子
        let scaledSpectrum = averagedSpectrum.map { $0 * scaleFactor }
        return scaledSpectrum
    }
}

