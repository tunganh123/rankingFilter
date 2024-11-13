//
//  Double++.swift
//  SpeedTest
//
//  Created by Tung Anh on 16/01/2024.
//

import Foundation

public extension Double {
    var toString: String {
        return "\(self)"
    }

    var degreesToRadians: Double {
        return self * .pi / 180
    }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
