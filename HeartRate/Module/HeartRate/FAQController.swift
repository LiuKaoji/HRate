//
//  FAQController.swift
//  HRate
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
            +++ Section("FAQ")
        <<< LabelRow { row in
                    row.title = "1. 如何将录音与Apple Watch的心率数据关联起来？"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "答：在开始录音时，确保您的Apple Watch已经连接到您的iPhone。应用程序将自动收集心率数据并与录音关联。在回放录音时，您可以查看与录音关联的心率数据。"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "2. 如何回放录音？"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "答：进入应用程序的播放界面，您可以查看您的录音列表。点击一个录音，将开始播放该录音。您还可以使用播放界面的控制按钮执行基本的音乐播放功能，如上一曲、下一曲、播放/暂停等。"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "3. 如何查看心率数据？"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "答：在播放录音时，您可以查看与录音关联的心率数据。应用程序提供了心率柱状图和曲线图，以便您更直观地查看数据。"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "4. 我没有Apple Watch，可以使用这个应用程序吗？"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "答：尽管应用程序的主要功能依赖于Apple Watch的心率数据，但即使没有手表，您仍然可以使用应用程序进行录音和回放。但是，您将无法查看与录音关联的心率数据。"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "5. 如何管理录音的权限和隐私设置？"
                    row.cell.textLabel?.numberOfLines = 0
                }
                <<< LabelRow { row in
                    row.title = "答：您可以在iPhone的“设置”应用中找到本应用程序的权限和隐私设置。在“隐私”菜单下，您可以管理麦克风访问权限等。确保允许应用程序访问您的麦克风以进行录音。"
                    row.cell.textLabel?.numberOfLines = 0
                }
                // 添加其他问题和答案，如上所示
            +++ Section()
                <<< ButtonRow { row in
                    row.title = "返回"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.navigationController?.popViewController(animated: true)
                }
    }
}
