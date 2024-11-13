//
//  UIImage+Extensions.swift
//  SpeedTest
//
//  Created by Tung Anh on 08/01/2024.
//

import Foundation
import UIKit
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
