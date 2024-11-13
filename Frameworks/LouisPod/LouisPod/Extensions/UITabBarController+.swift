//
//  UITabBarController+.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 28/08/2021.
//

import UIKit

extension UITabBarController {
    public func setTabBarHidden(_ isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        if tabBar.isHidden == isHidden {
            completion?()
        }
        
        if !isHidden {
            tabBar.isHidden = false
        }
        
        let height = tabBar.frame.size.height
        let offsetY = view.frame.height - (isHidden ? 0 : height)
        let duration = (animated ? 0.3 : 0.0)
        
        let frame = CGRect(origin: CGPoint(x: tabBar.frame.minX, y: offsetY), size: tabBar.frame.size)
        UIView.animate(withDuration: duration, animations: {
            self.tabBar.frame = frame
        }, completion: { _ in
            self.tabBar.isHidden = isHidden
            completion?()
        })
    }
}
