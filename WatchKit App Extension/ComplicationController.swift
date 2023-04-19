//
//  ComplicationController.swift
//  WatchKitApp Extension
//
//  Created by kaoji on 10/9/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // 获取最早的时间旅行日期
    private var earliestTimeTravelDate: Date {
        return CLKComplicationServer.sharedInstance().earliestTimeTravelDate
    }
    
    // 获取和设置最新心率数据的日期
    private var latestHeartRateDate: Date? {
        get {
            if let interval = UserDefaults.standard.value(forKey: "latestHeartRateDate") as? Double {
                return Date(timeIntervalSinceReferenceDate: interval)
            }
            return nil
        }
        set {
            let interval = newValue?.timeIntervalSinceReferenceDate
            UserDefaults.standard.set(interval, forKey: "latestHeartRateDate")
        }
    }
    
    // MARK: - 时间线配置
    
    // 获取支持的时间旅行方向
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward])
    }
    
    // 获取时间线的开始日期
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    // 获取时间线的结束日期
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    // 获取隐私行为
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    // MARK: - 时间线填充
    
    // 获取当前时间线条目
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // 使用当前时间线条目调用处理程序
        HeartRateController.sharedInstance.fetchHeartRates(startDate: nil, endDate: Date(), limit: 1) { heartRates, _ in
            var entry: CLKComplicationTimelineEntry?
            if let heartRate = heartRates.first {
                entry = self.timelineEntryForComplication(complication, heartRate: heartRate)
            }
            handler(entry)
        }
    }
    
    // 获取指定日期之前的时间线条目
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // 使用给定日期之前的时间线条目调用处理程序
        
        let startDate = latestHeartRateDate ?? earliestTimeTravelDate
        let endDate = date
        
        guard startDate < endDate else {
            handler(nil)
            return
        }
        
        HeartRateController.sharedInstance.fetchHeartRates(startDate: startDate, endDate: endDate, limit: limit) { heartRates, _ in
            
            let entries = heartRates.reversed().map {
                self.timelineEntryForComplication(complication, heartRate: $0)
            }
            
            if let latestEntry = entries.last {
                self.latestHeartRateDate = latestEntry.date
            }
            
            print("handle entries.count \(entries.count)")
            
            handler(entries)
        }
    }
    
    
    // MARK: - 占位符模板
    
    // 获取本地化的示例模板
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?)-> Void) {
        var sampleTemplate: CLKComplicationTemplate?
            
           switch complication.family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "76 BPM", shortText: "76", accessibilityLabel: "Heart Rate 76 BPM")
                template.line2TextProvider = CLKTimeTextProvider(date: Date())
                sampleTemplate = template
                
            case .utilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "76 BPM", shortText: "76", accessibilityLabel: "Heart Rate 76 BPM")
                sampleTemplate = template
                
            // ... 其他表盘样式的处理逻辑

            default:
                break
            }
            
            // 使用 Health app 的着色
            sampleTemplate?.tintColor = UIColor(red: 1, green: 40/255, blue: 81/255, alpha: 1)
            
            handler(sampleTemplate)
    }
    
    // 扩展时间线
    public func extendTimeline() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.extendTimeline(for: complication)
        }
    }
    
    // MARK: - 条目
    
    /// 获取特定 complication 和心率的时间线条目。
    /// - parameter heartRate: 默认值为 nil。设置非空值以获取实际日期和心率值的时间线条目。
    /// - returns: 如果 heartRate 为 nil，则返回用于 Apple Watch 的 complication 选择屏幕的占位符条目。
    private func timelineEntryForComplication(_ complication: CLKComplication, heartRate: HeartRate? = nil) -> CLKComplicationTimelineEntry {
        
        let heartRateText = "\(heartRate?.bpm ?? 76) BPM"
           let heartRateDate: Date = heartRate?.date ?? Date()

           let timeTextProvider = CLKTimeTextProvider(date: heartRateDate)
           let complicationTemplate = createComplicationTemplate(for: complication, heartRateText: heartRateText, timeTextProvider: timeTextProvider)

           guard let template = complicationTemplate else {
               fatalError("Unsupported complication family.")
           }

           return CLKComplicationTimelineEntry(date: heartRateDate, complicationTemplate: template)
    }
    
    private func createComplicationTemplate(for complication: CLKComplication, heartRateText: String, timeTextProvider: CLKTimeTextProvider) -> CLKComplicationTemplate? {
        var complicationTemplate: CLKComplicationTemplate? = nil

        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: heartRateText, shortText: "", accessibilityLabel: heartRateText)
            template.line2TextProvider = timeTextProvider
            complicationTemplate = template

        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: heartRateText, shortText: "", accessibilityLabel: heartRateText)
            complicationTemplate = template

        // ... 添加其他表盘样式的处理逻辑 ...

        default:
            break
        }

        // 使用 Health app 的着色
        complicationTemplate?.tintColor = UIColor(red: 1, green: 40/255, blue: 81/255, alpha: 1)

        return complicationTemplate
    }

}

