//
//  PlayList.swift
//  HRTune
//
//  Created by kaoji on 5/13/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit


class PlayList: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var stripesPagingView: PagingView!
    @IBOutlet weak var imgBackView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnNextAction: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var searchTF: SearchTextField!
    @IBOutlet weak var defaultListButton: UIButton!
    @IBOutlet weak var maskTableView: UIView!

    let topMask = CAGradientLayer()
    let btmMask = CAGradientLayer()
     
    // MARK: - Properties
    private var infos: [PageInfo] = PageInfo.infos
    private var selectedPageInfoIndex = 0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupTableView()
        setupPagingViews()
        setupActionButton()
        setupSearchStyle()
        setupGestureRecognizers()
    }
    
    func setupTableView() {
       
        tableView.register(PlayListCell.self, forCellReuseIdentifier: "PlayListCell")
        tableView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         tableView.layer.cornerRadius = 10
         
         topMask.colors = [UIColor.black.withAlphaComponent(0.3).cgColor,
                                 UIColor.black.cgColor,
                           UIColor.black.withAlphaComponent(0.3).cgColor]
         topMask.frame = maskTableView.bounds
         topMask.locations = [0, 0.5, 1]
         
         // 设置tableView父容器tableViewCotainer的遮罩
         maskTableView.layer.mask = topMask

    }
     
     func updatePageInfoImage(image: UIImage?){
          if let image = image {
               reloadData(image)
               return
          }
     }
     
     private func setupGestureRecognizers() {
         let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
         swipeLeft.direction = .left
         addGestureRecognizer(swipeLeft)
         
         let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
         swipeRight.direction = .right
         addGestureRecognizer(swipeRight)
     }

     @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
         switch gesture.direction {
         case .left:
              stripesPagingView.prevItem()
         case .right:
              stripesPagingView.nextItem()
         default:
             break
         }
     }
    
    private func setupPagingViews() {
        let setupPagingView: (PagingView, CGFloat, Bool) -> Void = { pagingView, cornerRadiusFactor, isCircles in
            pagingView.count = self.infos.count
            pagingView.fillingAnimationDuration = 0.32
            pagingView.cornerRadiusFactor = cornerRadiusFactor
            pagingView.isCircles = isCircles
            pagingView.color = isCircles ? UIColor.white.withAlphaComponent(0.32) : UIColor.white.withAlphaComponent(1)
            if isCircles {
                pagingView.scalingAnimationDuration = 0.32
                pagingView.scalingAnimationFactor = 1.32
            }
        }
        
        setupPagingView(stripesPagingView, 2, true)
    }
    
    private func setupActionButton() {
        btnNextAction.backgroundColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1)
        btnNextAction.setTitleColor(.white, for: .normal)
        btnNextAction.layer.cornerRadius = 8
    }
    
     func setupSearchStyle(){
          searchTF.startVisibleWithoutInteraction = false
          searchTF.placeholder = "请输入文件名"
          let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20)) // 10是左边距的大小
          searchTF.leftView = paddingView
          searchTF.leftViewMode = .always
     }
     
    // MARK: - Data
     public func reloadData(_ cover: UIImage? = nil) {
        let card = infos[selectedPageInfoIndex]
        let image = (cover != nil) ?cover:card.image
        
        lblTitle.text = card.title
        lblDetails.text = card.details
        imgBackView.setImageWithTransitionAnimation(image, options: [.transitionCrossDissolve])
        imgIcon.setImageWithTransitionAnimation(card.icon, options: [.transitionFlipFromLeft])
    }
    
    // MARK: - PageInfo Actions
    private func nextPageInfo() {
        selectedPageInfoIndex = (selectedPageInfoIndex + 1) % infos.count
        updatePageInfoAndPagingViews()
    }
    
    private func previousPageInfo() {
        selectedPageInfoIndex = (selectedPageInfoIndex - 1 + infos.count) % infos.count
        updatePageInfoAndPagingViews()
    }
    
    private func updatePageInfoAndPagingViews() {
        stripesPagingView.nextItem()
        reloadData()
    }
     
     public func switchToPage(index: Int) {
          selectedPageInfoIndex = index
          stripesPagingView.toItem(index: index)
          reloadData()
     }
     
     public func updatePageInfo(index: Int) {
          guard index != selectedPageInfoIndex else {return}
          selectedPageInfoIndex = index
          reloadData()
     }
}

// MARK: - UIImageView fileprivate extension
fileprivate extension UIImageView {
    func setImageWithTransitionAnimation(_ image: UIImage?, options: UIView.AnimationOptions = []) {
        UIView.transition(with: self, duration: 0.64, options: options, animations: { [weak self] in self?.image = image }, completion: nil)
    }
}

