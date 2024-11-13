//
//  UILabel.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    func adjustFontSizeToFitWidth(originFont: UIFont) {
        guard let text = self.text else { return }
            
        let labelWidth = frame.size.width
        let maxFontSize: CGFloat = originFont.pointSize
        let minFontSize: CGFloat = 6
            
        var fontSize = maxFontSize
            
        let constraintSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        while fontSize > minFontSize {
            // Tạo font mới với kích thước fontSize hiện tại
            let font = UIFont.systemFont(ofSize: fontSize)
                
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let labelSize = attributedText.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)
                
            // Kiểm tra nếu kích thước text phù hợp với chiều cao của label
            if labelSize.height <= frame.size.height {
                break
            }
                
            fontSize -= 1
        }
            
        // Cập nhật lại font của label với kích thước phù hợp
        font = UIFont.systemFont(ofSize: fontSize)
    }
    
    func underLine() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
    
    func setup(text: String?, font: UIFont, textColor: UIColor, alignment: NSTextAlignment, backgroundColor: UIColor = .clear) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.text = text
        self.textAlignment = alignment
    }
    
    func setLineSpacing(lineHeight: CGFloat = 0.0,
                        alignment: NSTextAlignment,
                        lineSpace: CGFloat = 0.0,
                        lineBreakMode: NSLineBreakMode = .byWordWrapping)
    {
        guard let labelText = text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        
        let lineHeightMultiple = lineHeight / font.lineHeight
        
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineSpacing = lineSpace / 2
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributedString: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: labelText)
        }()
        
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
    
    /// Apply a hyperlink style for "link"
    ///
    /// - Parameters:
    ///   - link: text to make hyperlink style
    ///   - color: color for hyperlink style
    ///   - baselineOffset: space between text and the line
    func setHighlight(_ string: String, color: UIColor, font: UIFont) {
        let attributedString: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: text ?? "")
        }()
        
        let range = (attributedString.string as NSString).range(of: string)
        attributedString.addAttributes([.foregroundColor: color,
                                        .font: font,
                                        .underlineStyle: NSUnderlineStyle.single.rawValue],
                                       range: range)
        attributedText = attributedString
    }
    
    func setHighlights(_ strings: [String],
                       color: UIColor,
                       font: UIFont)
    {
        let attributedString: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: text ?? "")
        }()
        
        for string in strings {
            let range = (attributedString.string as NSString).range(of: string)
            attributedString.addAttributes([.foregroundColor: color,
                                            .font: font,
                                            .underlineStyle: NSUnderlineStyle.single.rawValue],
                                           range: range)
        }
        
        attributedText = attributedString
    }
    
    func setBaselineOffset(_ baselineOffset: CGFloat) {
        let attributedString: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: text ?? "")
        }()
        
        attributedString.addAttributes([.baselineOffset: baselineOffset], range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
    
    func setAttributes(_ attributes: [(text: String, font: UIFont, color: UIColor)],
                       lineHeight: CGFloat = 0.0,
                       alignment: NSTextAlignment = .left,
                       lineSpace: CGFloat = 0.0,
                       lineBreakMode: NSLineBreakMode = .byWordWrapping)
    {
        let attributedStrings: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: text ?? "")
        }()
        for (text, font, color) in attributes {
            let attr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
            attributedStrings.append(attr)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        let lineHeightMultiple = lineHeight / font.lineHeight
        
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode

        attributedStrings.addAttribute(.paragraphStyle,
                                       value: paragraphStyle,
                                       range: NSRange(location: 0, length: attributedStrings.length))
        
        attributedText = attributedStrings
    }
    
    /// Create underline for current "text" by NSAttributedString
    func underline() {
        guard let textString = text else { return }
        let attributedString = NSMutableAttributedString(string: textString)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }

    func characterSpacing(_ spacing: CGFloat) {
        let attributedStrings: NSMutableAttributedString = {
            if let labelattributedText = attributedText {
                return NSMutableAttributedString(attributedString: labelattributedText)
            }
            return NSMutableAttributedString(string: text ?? "")
        }()
        attributedStrings.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: attributedStrings.length))
        attributedText = attributedStrings
    }
}
