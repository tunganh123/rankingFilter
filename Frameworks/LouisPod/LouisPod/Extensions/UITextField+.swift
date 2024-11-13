//
//  UITextField.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable public var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    public func setup(font: UIFont, textColor: UIColor, textAlignment: NSTextAlignment = .left, backgroundColor: UIColor = .clear) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.backgroundColor = backgroundColor
    }

    public func setColorPlaceholder(text: String, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: [NSAttributedString.Key.foregroundColor: color])
    }

    public func isWhiteSpaceOrEmpty() -> Bool {
        return text?.isWhiteSpaceOrEmpty ?? false
    }
    
    public func setPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
