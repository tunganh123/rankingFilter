//
//  UIImage.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

extension UIImage {
    public func isEqualToImage(_ image: UIImage) -> Bool {
        let data1 = self.pngData()
        let data2 = image.pngData()
        return data1 == data2
    }
    
    // to make up orientation
    public func png(isOpaque: Bool = true) -> Data? { flattened(isOpaque: isOpaque)?.pngData() }
    public func flattened(isOpaque: Bool = true) -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func resizedTo5MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024 * 5
        
        while imageSizeKB > 1024 * 5 {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024 * 5
        }
        
        return resizingImage
    }
    
    public func resizedToMB(_ mb: Double) -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024 * mb
        
        while imageSizeKB > 1024 * mb {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.8),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024 * mb
        }
        
        return resizingImage
    }
    
    public func scaledToSize(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func resizedToWidth(width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
          _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
      }
    
    func getUncachedImage(named name: String) -> UIImage? {
        if let imgPath = Bundle.main.path(forResource: name, ofType: ".png") {
            return UIImage(contentsOfFile: imgPath)
        } else {
            return UIImage(named: name)
        }
    }
    
    public class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}

// MARK: - Properties
extension UIImage {
    
    /// Size in bytes of UIImage
    public var bytesSize: Int {
        return jpegData(compressionQuality: 1)?.count ?? 0
    }
    
    /// Size in kilo bytes of UIImage
    public var kilobytesSize: Int {
        return (jpegData(compressionQuality: 1)?.count ?? 0) / 1024
    }
    
    /// UIImage with .alwaysOriginal rendering mode.
    public var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    
    /// UIImage with .alwaysTemplate rendering mode.
    public var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }
    
    public func getImageData() -> Data? {
        if let data = self.pngData() {
            return data
        } else if let data = self.jpegData(compressionQuality: 1) {
            return data
        }
        return nil
    }
    
    public func getImageName() -> String {
        if self.pngData() != nil {
            return ProcessInfo.processInfo.globallyUniqueString + ".png"
        } else if self.jpegData(compressionQuality: 1) != nil {
            return ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
        }
        return ProcessInfo.processInfo.globallyUniqueString + ".png"
    }
    
    public func convertImageToBase64String () -> String {
        let imageData: NSData = self.jpegData(compressionQuality: 1)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        return imgString
    }
    
    public func createThumb(width: Float)-> UIImage?{
        let imageData = self.pngData()!
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: width] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnail = UIImage(cgImage: imageReference)
        return thumbnail
    }
}
