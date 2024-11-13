//
//  TabbarViewController.swift
//  Ar-draw
//
//  Created by TungAnh on 13/6/24.
//
import LouisPod
import UIKit
import AdsMediationManager
class TabbarViewController: UITabBarController {
    let square: CGFloat = 64
    var widthBt: CGFloat = 200
    var isTheFirst = true
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configTab()
    }
    
    func configTab() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.backgroundColor = .white
        }
        tabBar.tintColor = UIColor(hex: "#8A64E8")
//        let homeVC = BaseNavigationController(rootViewController: ViewHome())
//        let homeItem = UITabBarItem(title: "Drawings", image: UIImage(named: "tabbar_home")?.withRenderingMode(.alwaysTemplate), selectedImage: UIImage(named: "tabbar_home_sellect")?.withRenderingMode(.alwaysOriginal))
//        homeVC.tabBarItem = homeItem
//        
//        let textVC = BaseNavigationController(rootViewController: ViewText())
//        let textItem = UITabBarItem(title: "Text", image: UIImage(named: "tabbar_text")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_text_sellect")?.withRenderingMode(.alwaysOriginal))
//        textVC.tabBarItem = textItem
//        
//        let favoritesVC = BaseNavigationController(rootViewController: ViewFavorites())
//        let favoritesItem = UITabBarItem(title: "Favorites", image: UIImage(named: "tabbar_favorites")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_favorites_sellect")?.withRenderingMode(.alwaysOriginal))
//        favoritesVC.tabBarItem = favoritesItem
//        
//        let ProfileVC = BaseNavigationController(rootViewController: ViewProfile())
//        let settingItem = UITabBarItem(title: "My profile", image: UIImage(named: "tabbar_profile")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_profile_sellect")?.withRenderingMode(.alwaysOriginal))
//        ProfileVC.tabBarItem = settingItem
//        setViewControllers([homeVC, textVC, favoritesVC, ProfileVC], animated: false)
    }
}

extension TabbarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {return}
        switch index{
        case 0:
            break
        case 1:
            EventManager.logEvent("Text_tab_shown")
        case 2:
            EventManager.logEvent("Favorite_tab_shown")
        default:
            EventManager.logEvent("My_profile_tab_shown")
        }
    }
}
