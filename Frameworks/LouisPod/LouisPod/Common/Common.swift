//
//  Common.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

public class Common {
    public class func getFontForDeviceWithFontDefault(fontDefault:UIFont) -> UIFont {
        var font:UIFont = fontDefault
        font = UIFont(name: font.fontName, size: font.pointSize * ratioScreen) ?? UIFont()
        return font
    }
    
    public class func generateID() -> String {
        return UUID().uuidString
    }
    
    public class func updateAllScaleConstraints(forView view: UIView) {
        for subview in view.subviews {
            if subview.translatesAutoresizingMaskIntoConstraints == false {
                for constraint in subview.constraints {
                    constraint.constant = constraint.constant*ratioScreen
                }
            }
            updateAllScaleConstraints(forView: subview)
        }
    }
    
    public class func downloadImage(from url: URL, completion: @escaping((UIImage?) -> Void)) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            completion(UIImage(data: data) ?? nil)
        }
    }
    
    class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
