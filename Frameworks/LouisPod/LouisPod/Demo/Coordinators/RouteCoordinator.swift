//
//  RouteCoordinator.swift
//  GoogleCastDemo
//
//  Created by Tung Anh on 29/12/2023.
//
 
import Foundation
import UIKit

class RouteCoordinator {
    static let shared = RouteCoordinator()
    
    func show_to_view(navi: UINavigationController, viewdes: UIViewController) {
        navi.pushViewController(viewdes, animated: true)
    }

    //    // Show share
    func showshare(from root: UIViewController, urlshare: URL, nameshare: String) {
        let items: [Any] = [nameshare, urlshare]
        // Tạo UIActivityViewController với mảng nội dung bạn muốn chia sẻ.
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // Nếu bạn muốn hiển thị một popover trên iPad, bạn có thể cấu hình nó như sau:
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = root.view // Chỉ định view mà popover sẽ hiển thị từ.
            popoverController.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0) // Chỉ định vị trí của popover.
            popoverController.permittedArrowDirections = [] // Xóa hướng mũi tên trên popover.
        }
        // Hiển thị UIActivityViewController.
        root.present(activityViewController, animated: true, completion: nil)
    }
    
    // showNavi_iap
    func performToNavi_iap(from root: UIViewController) {
        root.performSegue(withIdentifier: "showNavi_iap", sender: root)
    }
    
    func performToShowaddKeyword(from root: UIViewController) {
        root.performSegue(withIdentifier: "showaddKeyword", sender: root)
    }

    func performToDes_show_custom(from root: UIViewController) {
        root.performSegue(withIdentifier: "des_show_custom", sender: root)
    }

    func performSetting_to_intro(from root: UIViewController) {
        root.performSegue(withIdentifier: "setting_to_intro", sender: root)
    }

    func performToIntro(from root: UIViewController) {
        root.performSegue(withIdentifier: "showintro", sender: root)
    }
    
    func performToSetting(from root: UIViewController) {
        root.performSegue(withIdentifier: "showsetting", sender: root)
    }
    
    func performToCustom(from root: UIViewController) {
        root.performSegue(withIdentifier: "showcustom", sender: root)
    }

    func performToAll_iap(from root: UIViewController) {
        root.performSegue(withIdentifier: "show_all_iap", sender: root)
    }
 
    func performTomain(from root: UIViewController) {
        root.performSegue(withIdentifier: "showtoMain", sender: root)
    }

    func performToNavi_main(from root: UIViewController) {
        root.performSegue(withIdentifier: "showmain", sender: root)
//        if let Navimain = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Navimain") as? UINavigationController {
//            // Gọi pushViewController với animation = false
//            Navimain.modalPresentationStyle = .fullScreen
//            Navimain.modalTransitionStyle = .crossDissolve
//            root.present(Navimain, animated: true)
//        }
    }
}
