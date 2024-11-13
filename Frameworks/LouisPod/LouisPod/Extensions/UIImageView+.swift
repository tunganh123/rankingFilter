//
//  UIImageView.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit
//import SDWebImage

extension UIImageView {
//    public func setImage(with url: URL?, placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
//        self.contentMode = .scaleAspectFill
//        self.sd_imageTransition = .fade
//        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        self.sd_setImage(with: url,
//                         placeholderImage: placeholderImage,
//                         options: .refreshCached) { (image, _, _, _) in
//            completion?(image)
//        }
//    }
    
    public func roundCornersForAspectFit(radius: CGFloat) {
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect: CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
