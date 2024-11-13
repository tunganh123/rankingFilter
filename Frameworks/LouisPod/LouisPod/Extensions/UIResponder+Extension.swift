//
//  UIResponder+Extension.swift
//  tip-calculator
//
//  Created by Kelvin Fok on 23/12/22.
//

import UIKit

public extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
