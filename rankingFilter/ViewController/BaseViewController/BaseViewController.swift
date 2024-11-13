//
//  BaseViewController.swift
//  Ar-draw
//
//  Created by DucVV on 13/06/2024.
//

import Foundation
import LouisPod
import UIKit

class BaseViewController: UIViewController {
    var rightImage = UIImage()
      
    let width: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor(hex: "#FCF8FB")
    }
    
    func setLeftAlignTitleView(font: UIFont?, text: String, textColor: UIColor) {
        guard let navFrame = navigationController?.navigationBar.frame else {
            return
        }
        
        let parentView = UIView(frame: CGRect(x: 10, y: 0, width: navFrame.width * 3, height: navFrame.height))
        navigationItem.titleView = parentView
        let imageVIew = UIImageView(frame: CGRect(x: 10, y: (navFrame.height - 30) / 2, width: 30, height: 30))
        imageVIew.image = UIImage(named: "ic_logo")
        let label = UILabel(frame: .init(x: 46, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = font
        label.textAlignment = .left
        label.textColor = textColor
        label.text = text
        parentView.addSubview(imageVIew)
        parentView.addSubview(label)
    }

    func setFontTitleView(font: UIFont?, text: String, textColor: UIColor) {
        guard let navFrame = navigationController?.navigationBar.frame else {
            return
        }
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width, height: navFrame.height))
        navigationItem.titleView = parentView
        
        let label = UILabel(frame: .init(x: parentView.frame.minX, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.center = parentView.center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = font
        label.textAlignment = .left
        label.textColor = textColor
        label.text = text
        
        parentView.addSubview(label)
    }
  
    func addRightTextItem(title: String, tintColor: UIColor = UIColor(hex: "#8A64E8")) {
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(actionRightItem))
        item.tintColor = tintColor
        navigationItem.rightBarButtonItem = item
    }
    
    func setupNavi(title: String, imageLeft: String? = nil, imageRight: String? = nil) {
        self.title = title
        if let imageLeft = imageLeft {
            addLeftItem(imageName: imageLeft)
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        if let imageRight = imageRight {
            addRightItem(imageName: imageRight)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func addLeftItem(imageName: String) {
        let item = UIBarButtonItem(
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal),
            style: .plain, target: self,
            action: #selector(actionLeftItem))
        navigationItem.leftBarButtonItem = item
    }
    
    public func addRightItem(imageName: String) {
        if let image = UIImage(named: imageName) {
            let item = UIBarButtonItem(
                image: image.withRenderingMode(.alwaysOriginal),
                style: .plain, target: self,
                action: #selector(actionRightItem))
            navigationItem.rightBarButtonItem = item
        }
    }
    
    @objc func goIAP() {
        guard let parent = UIApplication.topViewController() else { return }
        let vc = IAPViewController()
        let navi = BaseNavigationController(rootViewController: vc)
        navi.modalTransitionStyle = .crossDissolve
        navi.modalPresentationStyle = .overFullScreen
        parent.present(navi, animated: true)
    }
    
    func addMoreRightItem(imageName: String, handle: Selector?, isSide: Bool = true) {
        if let image = UIImage(named: imageName) {
            let item = UIBarButtonItem(
                image: image.withRenderingMode(.alwaysTemplate),
                style: .plain, target: self,
                action: handle)
            navigationItem.rightBarButtonItems?.insert(item, at: isSide ? 0 : navigationItem.rightBarButtonItems?.count ?? 0)
        }
    }
    
    @objc func actionLeftItem() {
        print("Left Action")
    }
    
    @objc func actionRightItem() {
        print("Right Action")
    }
}
