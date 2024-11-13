//
//  String++.swift
//  HeadUptest
//
//  Created by TungAnh on 8/5/24.
//

import CommonCrypto
import CryptoKit
import Foundation
import UIKit

public extension String {
    func encode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    internal static func / (lhs: String, rhs: String) -> String {
        lhs + "/" + rhs
    }
    
    func MD5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    func capitalizeFirstLetter() -> String {
        guard let firstCharacter = self.first else {
            return self
        }
        return firstCharacter.uppercased() + self.dropFirst()
    }
}

public extension String {
    var isPngFile: Bool {
        return contains(".png")
    }
    
    var toInt: Int {
        Int(self) ?? 0
    }
    
    func convertStringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.date(from: self) ?? Date()
    }
    
    var isWhiteSpaceOrEmpty: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func trimming() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }
    
    var containsWhitespace: Bool {
        return self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return ceil(boundingBox.width)
    }
    
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func convertBase64StringToImage() -> UIImage? {
        let imageData = Data(base64Encoded: self, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image
    }
}

// MARK: - Regexs

public extension String {
    var isEmail: Bool {
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    var isOnlyLetters: Bool {
        let regexString = "[a-zA-Z_]+"
        return self.validate(withRegex: regexString)
    }
    
    var isAlphanumeric: Bool {
        let regexString = "[a-zA-Z0-9_]+"
        return self.validate(withRegex: regexString)
    }
    
    var isNumeric: Bool {
        let regexString = "^(?:[0-9])+$"
        return self.validate(withRegex: regexString)
    }
    
    func validate(withRegex regexString: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regexString)
            let result = regex.firstMatch(in: self,
                                          options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                          range: NSRange(location: 0, length: count)) != nil
            return result
        } catch {
            return false
        }
    }
}
