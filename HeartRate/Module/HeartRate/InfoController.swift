//
//  InfoController.swift
//  HRate
//
//  Created by kaoji on 4/22/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Eureka


class UserInfoFormViewController: FormViewController {
    
    let persistManager = PersistManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图的背景颜色为半透明
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
        // 设置圆角边框
        let formView = UIView()
        formView.backgroundColor = .white
        formView.layer.cornerRadius = 10
        formView.layer.masksToBounds = true
        formView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formView)
        
        // 设置表单视图的约束
        NSLayoutConstraint.activate([
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            formView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        // 将表格视图添加到 formView 中
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewStyle = .insetGrouped
        formView.addSubview(tableView)
        
        // 设置表格视图的约束
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        tableView.isScrollEnabled = false

        
        // 获取已存储的用户信息
        let userInfo = persistManager.getUserInfo()
        form +++ Section(header: "个人信息", footer: "您的隐私信息仅用于本地计算体能消耗")
        

        <<< SegmentedRow<String>("gender") {
            $0.title = "性别"
            $0.options = ["男", "女"]
            $0.value = userInfo?.gender == 0 ? "男" : "女"
        }

        <<< PickerInlineRow<Int>("weight") {
            $0.title = "体重 (kg)"
            $0.options = Array(40...100)
            $0.value = userInfo?.weight
        }.onChange { [weak self] _ in
            self?.resetTableViewOffset()
        }

        <<< PickerInlineRow<Int>("age") {
            $0.title = "年龄"
            $0.options = Array(10...70)
            $0.value = userInfo?.age
        }.onChange { [weak self] _ in
            self?.resetTableViewOffset()
        }

        <<< PickerInlineRow<Int>("height") {
            $0.title = "身高 (cm)"
            $0.options = Array(150...190)
            $0.value = userInfo?.height
        }.onChange { [weak self] _ in
            self?.resetTableViewOffset()
        }
        
        +++ Section()
        
        <<< ButtonRow {
            $0.title = "保存"
            $0.cell.tintColor = UIColor(red: 28/255, green: 35/255, blue: 64/255, alpha: 1)
            $0.cell.backgroundColor = .white
            $0.cell.layer.cornerRadius = 5
            $0.cell.layer.masksToBounds = true
        }
        .onCellSelection { [weak self] _, _ in
            // 处理保存按钮点击事件，获取用户信息
            let formValues = self?.form.values() as? [String: Any]
            let gender = formValues?["gender"] as? String ?? ""
            let weight = formValues?["weight"] as? Int ?? 0
            let age = formValues?["age"] as? Int ?? 0
            let height = formValues?["height"] as? Int ?? 0
            
            // 保存用户信息
            self?.persistManager.updateUserInfo(
                gender: gender == "男" ? 0 : 1,
                weight: weight,
                age: age,
                height: height
            )
            
            // 关闭表单
            self?.dismiss(animated: true, completion: nil)
        }
        
        +++ Section()
        
        <<< ButtonRow {
            $0.title = "取消"
            $0.cell.tintColor = UIColor(red: 28/255, green: 35/255, blue: 64/255, alpha: 1)
            $0.cell.backgroundColor = .white
            $0.cell.layer.cornerRadius = 5
            $0.cell.layer.masksToBounds = true
        }
        .onCellSelection { [weak self] _, _ in
            // 取消操作，关闭表单
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func showUserInfoForm() {
        let userInfoFormVC = UserInfoFormViewController()
        
        // 设置视图控制器为半透明
        userInfoFormVC.modalPresentationStyle = .overCurrentContext
        userInfoFormVC.modalTransitionStyle = .crossDissolve
        
        // 显示视图控制器
        present(userInfoFormVC, animated: true, completion: nil)
    }
    
    func resetTableViewOffset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView.setContentOffset(.zero, animated: true)
        }
    }
}
