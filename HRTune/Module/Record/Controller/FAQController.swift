//
//  FAQController.swift
//  HRTune
//
//  Created by kaoji on 5/4/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class FAQController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("常见问题解答")
        
            <<< LabelRow { row in
                row.title = "1. 这个程序有什么功能？"
                row.cell.textLabel?.numberOfLines = 0
            } <<< LabelRow { row in
                row.title = "答：只要您拥有Apple Watch，我们的程序可以帮助您进行录音并记录实时心率。"
                row.cell.textLabel?.numberOfLines = 0
            }
        
            <<< LabelRow { row in
                row.title = "2. 手表端程序可以单独使用吗？"
                row.cell.textLabel?.numberOfLines = 0
            } <<< LabelRow { row in
                row.title = "答：可以的，您可以手动点击开始录音，并在运动过程中注意心率变化。"
                row.cell.textLabel?.numberOfLines = 0
            }
        
            <<< LabelRow { row in
                row.title = "3. 如何查看心率数据？"
                row.cell.textLabel?.numberOfLines = 0
            } <<< LabelRow { row in
                row.title = "答：在回放录音时，您可以右滑查看当前音频时间节点对应的心率数据及变化趋势。"
                row.cell.textLabel?.numberOfLines = 0
            }
        
            <<< LabelRow { row in
                row.title = "4. 我没有Apple Watch，能使用这个应用程序吗？"
                row.cell.textLabel?.numberOfLines = 0
            } <<< LabelRow { row in
                row.title = "答：尽管应用程序的主要功能基于Apple Watch的心率数据，但即使没有手表，您仍然可以使用应用程序进行录音和回放。不过，您将无法查看与录音相关的心率数据。"
                row.cell.textLabel?.numberOfLines = 0
            }
        
            <<< LabelRow { row in
                row.title = "5. 为什么音频包只有几首歌曲？"
                row.cell.textLabel?.numberOfLines = 0
            } <<< LabelRow { row in
                row.title = "答：如果您想获取或制作自己的音频包，或者体验已准备好的音频包，请点击此处下载完整的数据包，并通过iTunes将其同步到应用程序的文稿目录中。"
                row.cell.textLabel?.numberOfLines = 0
            }.onCellSelection { _, _ in
                UIApplication.shared.open(URL.init(string: "https://pan.baidu.com/s/1HmK8wXF4MSt6C9Vd6_JXVg?pwd=1122")!)
            }
    }
}
