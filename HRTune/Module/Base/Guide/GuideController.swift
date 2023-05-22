//
//  GuideView.swift
//  HRTune
//
//  Created by kaoji on 5/15/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit

class GuideView: UIView {
    typealias Element = (item: GuideItem, actions: [PVActionType])
    var pages: [[Element]]! // 用于存储页面的数组，每个页面都包含一组元素
    var itemViews = [String: UIView]() // 用于存储不同元素对应的视图
    
    var pageControl: UIPageControl! // 页面指示器，用于显示当前页面
    var parallaxView: PVView! // PVView 视图，用于实现视差效果
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1)
        
        pageControl = .init(frame: .zero)
        parallaxView = .init(frame: frame)
        addSubview(parallaxView)
        addSubview(pageControl)
        
        // 添加parallaxView
        parallaxView.translatesAutoresizingMaskIntoConstraints = false
        parallaxView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        parallaxView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        parallaxView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        parallaxView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // 添加pageControl
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true

        parallaxView.ignoreLastPage = true // 忽略最后一页的动画效果
        parallaxView.delegate = self // 设置代理对象为当前视图控制器
        
        startParallaxView() // 开始视差效果
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func showInWindow(){
        if let topWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            topWindow.addSubview(self)
        }
    }
    
    func hideFromWindow(){
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: .infinity, initialSpringVelocity: 0.2) {
            self.alpha = 0
        }completion: { isComplete in
            self.removeFromSuperview()
        }
    }
    
    
    func startParallaxView() {
        self.loadItemViews() // 加载元素视图
        self.loadActions() // 加载动作
        pageControl.numberOfPages = pages.count // 设置页面指示器的总页数
        parallaxView.scrollView.showsVerticalScrollIndicator = false
        parallaxView.scrollView.showsHorizontalScrollIndicator = false
        parallaxView.reload() // 刷新 PVView 视图
    }
    
    private func loadItemViews() {
        itemViews = [:]
        let iphoneImage = G.image.iphone()!
        let center = CGPoint(x: parallaxView.bounds.midX, y: parallaxView.bounds.midY)
        let iphoneView = UIView(frame: CGRect(origin: CGPoint(x: center.x - iphoneImage.size.width / 2, y: center.y - iphoneImage.size.height / 2), size: iphoneImage.size))
        let iphoneBgrView = UIImageView(image: iphoneImage)
        iphoneBgrView.frame = iphoneView.bounds
        iphoneView.addSubview(iphoneBgrView)
        iphoneView.isUserInteractionEnabled = false
        iphoneView.backgroundColor = UIColor.clear
        iphoneView.layer.transform.m34 = 1.0 / 500 //This make iphoneView has 3D rotating
        iphoneView.layer.zPosition = 50
        let iphoneScreenView = UIView(frame: iphoneView.bounds.insetBy(dx: 10, dy: 37))
        iphoneScreenView.layer.masksToBounds = true
        iphoneView.addSubview(iphoneScreenView)
        
        itemViews[GuideItem.iphoneBase.identifier] = iphoneView
        itemViews["iphoneScreen"] = iphoneScreenView
        itemViews[GuideItem.screen1.identifier] = UIImageView(image: G.image.screen_01()!)
        itemViews[GuideItem.screen2.identifier] = UIImageView(image: G.image.screen_02()!)
        itemViews[GuideItem.screen3.identifier] = UIImageView(image: G.image.screen_03()!)
        itemViews[GuideItem.screen4.identifier] = UIImageView(image: G.image.screen_04()!)
        itemViews[GuideItem.screen5.identifier] = UIImageView(image: G.image.screen_05_iphone()!)
        itemViews[GuideItem.searchBubble.identifier] = UIImageView(image: G.image.screen_02_bubble()!)
        itemViews[GuideItem.taskBubble.identifier] = UIImageView(image: G.image.screen_04_bubble()!)
        itemViews[GuideItem.contactIcon.identifier] = UIImageView(image: G.image.weight()!)
        itemViews[GuideItem.messageIcon.identifier] = UIImageView(image: G.image.height()!)
        itemViews[GuideItem.callingIcon.identifier] = UIImageView(image: G.image.age()!)
        itemViews[GuideItem.callingIcon.identifier] = UIImageView(image: G.image.age()!)
        itemViews[GuideItem.iWatch.identifier] = UIImageView(image: G.image.watch()!)
        itemViews[GuideItem.label0.identifier] = UILabel()
        itemViews[GuideItem.label1.identifier] = UILabel()
        itemViews[GuideItem.label2.identifier] = UILabel()
        itemViews[GuideItem.label3.identifier] = UILabel()
        itemViews[GuideItem.label4.identifier] = UILabel()
        

        [(GuideItem.contactIcon, CGPoint(x: center.x - 10, y: center.y - 15)),
         (.messageIcon, CGPoint(x: center.x + 25, y: center.y - 25)),
         (.callingIcon, CGPoint(x: center.x + 60, y: center.y - 30))].forEach { (item, center) in
            itemViews[item.identifier]?.center = center
        }

        
        [GuideItem.contactIcon, .messageIcon, .callingIcon, .iWatch].forEach {
            itemViews[$0.identifier]?.layer.zPosition = 1000
        }
        
        [(GuideItem.label0, "请确认已与手表配对"),
        (.label1, "请戴上并解锁您的手表"),
         (.label2, "请填写信息以计算消耗"),
         (.label3, "请授权读取心率数据"),
         (.label4, "开始记录您的心率吧")].forEach { (item, text) in
            let label = itemViews[item.identifier] as! UILabel
            label.text = text
            label.font = .boldSystemFont(ofSize: 20)
            label.textAlignment = .center
            label.textColor = .white
            label.frame.size = label.sizeThatFits(CGSize(width: self.bounds.width - 40, height: 50))
        }
        
    }
    
    func loadActions() {
        let midX = Double(parallaxView.bounds.midX)
        let midY = Double(parallaxView.bounds.midY)
        //Page 0
        let p0_iphone = [PVActionRotate(toZ: -Double.pi / 5), PVActionRotate(toY: -Double.pi / 6)]
        let p0_bubble = [PVActionGroup(actions: [PVActionScale(from: 0, to: 1.8),
                                                PVActionFade(from: 0),
                                                PVActionMove(fromPosition: PVPoint(x: 0.5, y: 0.1, isRelative: true),
                                                             toPosition: PVPoint(x: -0.2, y: 0.6, isRelative: true))],
                                       parameters: PVParameters(startOffset: 0.5))]
        let p0_label1: [PVActionBasicType] = [PVActionFade(from: 0), PVActionMove(fromPosition: PVPoint(x: 2, y: 0.2, isRelative: true), toPosition: PVPoint(x: 0.5, y: 0.2, isRelative: true)), LetterSpacingAction(fromSpacing: 20, toSpacing: 1.5, maxWidth: bounds.width)]
        let p0_screen1 = [PVActionMove(toTranslation: PVPoint(x: 0.86, y: 0, isRelative: true))]
        let p0_label0: [PVActionBasicType] = [PVActionFade(to: 0), PVActionMove(fromPosition: PVPoint(x: 0.5, y: 0.2, isRelative: true), toPosition: PVPoint(x: -1, y: 0.2, isRelative: true)), LetterSpacingAction(fromSpacing: 1.5, toSpacing: 20, maxWidth: bounds.width)]
        
        let page0: [Element] = [(.iphoneBase, p0_iphone),
                                (.label0, p0_label0),
                     (.searchBubble, p0_bubble),
                     (.screen2, []),
                     (.screen1, p0_screen1),
                     (.label1, p0_label1)]
        
        let p1_iphone = p0_iphone.reversedActions() + [PVActionRotate(toX: -Double.pi / 5)]
        let p1_screen3 = p0_screen1.reversedActions()
        let p1_bubble = p0_bubble.reversedActions(with: PVParameters(stopOffset: 0.5))
        let p1_contact = [PVActionGroup(actions: [PVActionScale(from: 0.0, to: 1.5), PVActionMove(fromPosition: PVPoint(x: midX - 10, y: midY - 15), toPosition: PVPoint(x: midX - 80, y: midY - 65))], parameters: PVParameters(startOffset: 0.6))]
        let p1_message = [PVActionGroup(actions: [PVActionScale(from: 0.0, to: 1.5), PVActionMove(fromPosition: PVPoint(x: midX + 25, y: midY - 25), toPosition: PVPoint(x: midX, y: midY - 115))], parameters: PVParameters(startOffset: 0.7))]
        let p1_calling = [PVActionGroup(actions: [PVActionScale(from: 0.0, to: 1.5), PVActionMove(fromPosition: PVPoint(x: midX + 60, y: midY - 30), toPosition: PVPoint(x: midX + 80, y: midY - 65))], parameters: PVParameters(startOffset: 0.8))]
        let p1_label1: [PVActionBasicType] = [PVActionFade(to: 0), PVActionMove(fromPosition: PVPoint(x: 0.5, y: 0.2, isRelative: true), toPosition: PVPoint(x: -1, y: 0.2, isRelative: true)), LetterSpacingAction(fromSpacing: 1.5, toSpacing: 20, maxWidth: bounds.width)]
        let p1_label2 = p0_label1
        let page1: [Element] = [(.iphoneBase, p1_iphone),
                                (.screen3, p1_screen3),
                                (.searchBubble, p1_bubble),
                                (.contactIcon, p1_contact),
                                (.messageIcon, p1_message),
                                (.callingIcon, p1_calling),
                                (.label1, p1_label1),
                                (.label2, p1_label2)]
        
        //Page 2
        let p2_contact = [PVActionGroup(actions: [PVActionScale(from: 1.5, to: 0), PVActionMove(fromPosition: PVPoint(x: midX - 80, y: midY - 65), toPosition: PVPoint(x: midX - 30, y: midY - 30))], parameters: PVParameters(stopOffset: 0.5))]
        let p2_message = [PVActionGroup(actions: [PVActionScale(from: 1.5, to: 0), PVActionMove(fromPosition: PVPoint(x: midX, y: midY - 115), toPosition: PVPoint(x: midX + 10, y: midY - 20))], parameters: PVParameters(stopOffset: 0.5))]
        let p2_calling = [PVActionGroup(actions: [PVActionScale(from: 1.5, to: 0), PVActionMove(fromPosition: PVPoint(x: midX + 80, y: midY - 65), toPosition: PVPoint(x: midX + 50, y: midY - 5))], parameters: PVParameters(stopOffset: 0.5))]
        let p2_screen4 = [PVActionMove(fromOrigin: PVPoint(x: 0, y: 1, isRelative: true), toOrigin: PVPoint.zero)]
        let p2_iphone = [PVActionRotate(toZ: Double.pi / 5), PVActionRotate(toY: Double.pi / 6), PVActionRotate(fromX: -Double.pi / 5)]
        let p2_bubble = [PVActionGroup(actions: [PVActionScale(from: 0, to: 1.8), PVActionFade(from: 0), PVActionMove(fromPosition: PVPoint(x: 0.2, y: 0.3, isRelative: true), toPosition: PVPoint(x: 1.0, y: 0.6, isRelative: true))], parameters: PVParameters(startOffset: 0.7))]
        let p2_label2 = p1_label1
        let p2_label3 = p0_label1
        let page2: [Element] = [(.contactIcon, p2_contact),(.messageIcon, p2_message),
                                (.callingIcon, p2_calling),(.screen4, p2_screen4),
                                (.iphoneBase, p2_iphone),(.taskBubble, p2_bubble),
                                (.label2, p2_label2),(.label3, p2_label3)]
        
        let p3_iphone = [PVActionGroup(actions: [PVActionRotate(fromZ: Double.pi / 5), PVActionRotate(fromY: Double.pi / 6), PVActionScale(to: 1.0), PVActionMove(fromPosition: PVPoint(x: midX, y: midY), toPosition: PVPoint(x: midX - 70, y: midY + 50))], parameters: PVParameters(timingFunction: PVTimingFunction(name: .easeInOutBack)))]
        
        let p3_screen5 = [PVActionFade(from: 0)]

        let p3_iWatch: [PVActionBasicType] =  [PVActionScale(to: 1.3), PVActionFade(from: 0), PVActionMove(fromPosition: PVPoint(x: midX + 100, y: midY + 35), toPosition: PVPoint(x: midX + 75, y: midY + 35))]
        let p3_bubble = p2_bubble.reversedActions(with: PVParameters(stopOffset: 0.4))
        let p3_label3 = p1_label1
        let p3_label4 = p0_label1
        let page3: [Element] = [(.iWatch, p3_iWatch),(.iphoneBase, p3_iphone),
                                (.screen5, p3_screen5),(.taskBubble, p3_bubble),
                                (.label3, p3_label3),(.label4, p3_label4)]
        
        pages = [page0, page1, page2, page3, []]
    }
}

extension GuideView: PVViewDelegate {
    func direction(of parallaxView: PVView) -> PVView.PVDirection {
        return .horizontal
    }
    
    func numberOfPages(in parallaxView: PVView) -> Int {
        return pages.count // 返回页面总数
    }
    
    func parallaxView(_ parallaxView: PVView, willBeginTransitionTo pageIndex: Int) {
        // 将要开始切换到某个页面时触发的回调方法
    }
    
    func parallaxView(_ parallaxView: PVView, itemsOnPage pageIndex: Int) -> [PVItemType] {
        return pages[pageIndex].map { $0.item } // 返回指定页面上的所有元素
    }
    
    func parallaxview(_ parallaxView: PVView, viewForItem item: PVItemType) -> UIView {
        return itemViews[item.identifier]! // 返回指定元素对应的视图
    }
    
    func parallaxView(_ parallaxView: PVView, containerViewForItem item: PVItemType, onPage pageIndex: Int) -> UIView? {
        let item = item as! GuideItem
        switch item {
        case .screen1, .screen2, .screen3, .screen4, .screen5:  return itemViews["iphoneScreen"] // 返回用于包裹屏幕元素的视图
        case  .searchBubble, .taskBubble: return itemViews[GuideItem.iphoneBase.identifier] // 返回用于包裹弹出元素的视图
        default: return nil }
    }
    
    func parallaxView(_ parallaxView: PVView, actionsOfItem item: PVItemType, onPage pageIndex: Int) -> [PVActionType] {
        return pages[pageIndex].first(where: { $0.item.identifier == item.identifier })?.actions ?? [] // 返回指定元素在当前页面上的动作数组
    }

    func parallaxView(_ parallaxView: PVView, didEndTransitionFrom previousPageIndex: Int?) {
        guard let currentIndex = parallaxView.currentPageIndex else { return }
        pageControl.currentPage = currentIndex // 更新页面指示器的当前页
        
        // 在特定条件下执行一些动画或其他操作
        if currentIndex == 0 && previousPageIndex == nil {
            if let iphone = itemViews[GuideItem.iphoneBase.identifier] {
                iphone.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    iphone.alpha = 1
                }
            }
        }
    }
}
