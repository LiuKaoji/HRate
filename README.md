# HRate 将心率与录音关联起来
  

 ![IMG_8823](https://github.com/LiuKaoji/HRate/assets/47659827/2403973f-6eec-44a8-98c1-0a621ea32549)

  https://user-images.githubusercontent.com/47659827/231647479-57ce7081-b2bf-46d9-bf0b-5cd96db1fe51.mp4


## 功能和特点
- 跨设备支持：通过 iPhone 和 Apple Watch 实现心率监测与音频记录的同步。
- 实时心率展示：在 Apple Watch 和 iPhone 上实时显示心率数据。
- 音频关联：将心率数据与音频记录关联，方便用户回顾和分析。
- 数据可视化：利用图表展示心率数据，帮助用户更直观地了解心率变化。

## 技术栈
- 使用 Swift 编程语言进行开发， SwiftUI构建AppleWatch界面
- 利用 Apple Watch 和 iPhone 的 WatchConnectivity 框架实现设备间通信。
- 通过 HealthKit 框架获取和展示心率数据。

## 系统要求
- iPhone 设备需运行 iOS 13 或更高版本。
- Apple Watch 设备需运行 watchOS 5 或更高版本。


```mermaid
sequenceDiagram
    participant iPhone as iPhone
    participant AppleWatch as AppleWatch
    participant HRateiPhone as HRate iPhone App
    participant HRateAppleWatch as HRate AppleWatch App
    participant HealthKitApp as HealthKit App
    
    iPhone->>HRateiPhone: 启动App，注册WCSession消息监听
    iPhone->>HRateiPhone: 点击录制按钮
    iPhone->>HRateAppleWatch: 唤醒HRate AppleWatch App
    HRateAppleWatch->>iPhone: 唤醒成功
    iPhone->>HRateiPhone: 开始录音
    HRateAppleWatch->>HRateAppleWatch: 启动心率检测
    HRateAppleWatch->>HRateAppleWatch: 显示心率数据
    HRateAppleWatch->>HRateiPhone: 发送心率数据至iPhone
    HealthKitApp->>HealthKitApp: 使用HealthKit检测心率
    HealthKitApp->>HealthKitApp: 将心率数据进行图表展示
    HealthKitApp->>HRateiPhone: 通过WCSession将心率发送至HRate iPhone App
    HRateiPhone->>iPhone: 显示心率数据
    HRateiPhone->>iPhone: 音频关联
    iPhone->>HRateiPhone: 点击停止
    iPhone->>HRateiPhone: 停止录音，保存心率数据
    iPhone->>HRateiPhone: 发送消息关闭HRate AppleWatch App
```
  



