//
//  Vibrate_manager.swift
//  LouisPod
//
//  Created by TungAnh on 24/5/24.
//

import Foundation
import UIKit

public class VibrationManager {
    public static let shared = VibrationManager()

    private init() {}

    public func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle, name: String) {
        let generator = UIImpactFeedbackGenerator(style: style)
        let check_Vibrate_permiss = (UserDefaults.standard.object(forKey: name))
        if check_Vibrate_permiss != nil, (check_Vibrate_permiss as! Bool) == true {
            generator.impactOccurred()
        }
    }
}
