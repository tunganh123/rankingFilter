//
//  BaseNavigationController.swift
//  Ar-draw
//
//  Created by TungAnh on 13/6/24.
// 
import LouisPod
import UIKit

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = .clear
        navigationBar.tintColor = .black
        navigationBar.prefersLargeTitles = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        let imgBack = UIImage(named: "ic_back")
        navigationBar.backIndicatorImage = imgBack
        navigationBar.backIndicatorTransitionMaskImage = imgBack
        navigationItem.leftItemsSupplementBackButton = true

        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 20)
        ]

        if #available(iOS 15.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithOpaqueBackground()
            barAppearance.backgroundColor = .clear
            barAppearance.backgroundImage = UIImage(named: "ic_top_nav")
            barAppearance.shadowColor = nil
            barAppearance.shadowImage = nil
            let imgBack = UIImage(named: "ic_back") ?? UIImage()
            barAppearance.setBackIndicatorImage(imgBack, transitionMaskImage: imgBack)

            barAppearance.titleTextAttributes = [.foregroundColor: UIColor.black,
                                                 NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 20)]

            navigationBar.standardAppearance = barAppearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
