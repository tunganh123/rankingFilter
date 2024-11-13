//
//  UIButton.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

extension UIButton {
    public func setTitleWithoutAnimation(_ title: String?) {
        UIView.performWithoutAnimation {
            setTitle(title, for: .normal)
            layoutIfNeeded()
        }
    }
    
    public func setImageWithoutAnimation(_ image: UIImage?) {
        UIView.performWithoutAnimation {
            setImage(image, for: .normal)
            layoutIfNeeded()
        }
    }
    
    public func setAttributes(_ attributes: [(text: String, font: UIFont, color: UIColor)],
                       lineHeight: CGFloat = 0.0,
                       alignment: NSTextAlignment = .center,
                       lineSpace: CGFloat = 0.0,
                       lineBreakMode: NSLineBreakMode = .byTruncatingTail, controlState: UIControl.State = .normal) {
        guard !attributes.isEmpty else {
            return
        }
        titleLabel?.numberOfLines = 0
        let attributedStrings = NSMutableAttributedString(string: "")
        attributes.forEach { (text, font, color) in
            let attr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
            attributedStrings.append(attr)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        
        let lineHeightMultiple = lineHeight / attributes[0].font.lineHeight
        
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        attributedStrings.addAttribute(.paragraphStyle,
                                       value: paragraphStyle,
                                       range: NSRange(location: 0, length: attributedStrings.length))
        setAttributedTitle(attributedStrings, for: controlState)
    }
    
    public func setup(title: String,
               font: UIFont,
               titleColor: UIColor,
               imageBackground: UIImage,
               controlState: UIControl.State = .normal) {
        self.titleLabel?.font = font
        self.setTitleColor(titleColor, for: controlState)
        self.setTitle(title, for: controlState)
        self.backgroundColor = backgroundColor
        self.setBackgroundImage(imageBackground, for: controlState)
    }

    public func swapImage() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    public enum AttributeStringType {
        case fontStyle(UIFont)
        case underline
    }
    
    public func setAttributeString(subTexts: [String], types: [AttributeStringType]) {
        let attributeString = NSMutableAttributedString(string: titleLabel?.text ?? "")
        
        subTexts
            .map { ((titleLabel?.text ?? "") as NSString).range(of: $0) }
            .forEach { rangeText in
                for type in types {
                    switch type {
                    case let .fontStyle(font):
                        attributeString.addAttribute(NSAttributedString.Key.font,
                                                     value: font,
                                                     range: rangeText)
                    case .underline:
                        attributeString.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                                                      range: rangeText)
                    }
                }
            }
        setAttributedTitle(attributeString, for: .normal)
    }
}
