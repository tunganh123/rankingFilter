//
//  NSObject+.swift
//  LouisPod
//
//  Created by DucVV on 13/06/2024.
//

import Foundation
extension NSObject {
    public var className: String {
        return type(of: self).className
    }
    
    public static var className: String {
        return String(describing: self)
    }
    
    public func getImage(_ url:URL) -> UIImage? {
        if let data = try? Data.init(contentsOf: url){
            return UIImage.init(data: data)
        }
        return nil
    }
}
