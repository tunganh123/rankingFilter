//
//  Int+.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 18/05/2022.
//  Copyright © 2022 nguyen.viet.luy. All rights reserved.
//

import Foundation

extension Int {
    public func roundedWithAbbreviations() -> String {
        let number = Double(self)
        let thousand = (number / 1000)
        let million = (number / 1000000)
        if million >= 1.0 {
            return String(format: "%0.1fM", million)
        }
        else if thousand >= 1.0 {
            return String(format: "%0.1fK", thousand)
        }
        else {
            return "\(self)"
        }
    }
    
    public func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)
        let abbreviations: [Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        // you can add more !
        
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
    
    public var toString: String {
        return "\(self)"
    }
    
    public func secondsToMinutesSeconds() -> (String, String) {
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return (m > 9 ? "\(m)" : "0\(m)", s > 9 ? "\(s)" : "0\(s)")
    }
    
    public func secondsToHoursMinutesSeconds() -> (String, String, String) {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return (h > 9 ? "\(h)" : "0\(h)", m > 9 ? "\(m)" : "0\(m)", s > 9 ? "\(s)" : "0\(s)")
    }
    
    public func secondsToDaysHoursMinutes() -> (String, String, String) {
        let d = self / 86400
        let h = (self % 86400) / 3600
        let m = (self % 3600) / 60
        return (d > 9 ? "\(d)" : "0\(d)", h > 9 ? "\(h)" : "0\(h)", m > 9 ? "\(m)" : "0\(m)")
    }
    
    public func splitDays() -> (String, String, String) {
        let d = self / 100
        let h = (self % 100) / 10
        let m = (self % 10)
        return ("\(d)", "\(h)", "\(m)")
    }
    
    public func secondsToHoursMinutesSecondsString() -> String {
        if self >= 3600{
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            let seconds = (self % 3600) % 60
            
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            return timeString
        }
        else{
            if self >= 600{
                let minutes = (self % 3600) / 60
                let seconds = (self % 3600) % 60
                
                let timeString = String(format: "%02d:%02d", minutes, seconds)
                return timeString
            }
            else{
                let seconds = (self % 3600) % 60
                let minutes = (self % 3600) / 60
                let timeString = String(format: "%01d:%02d", minutes, seconds)
                return timeString
            }
        }
    }
}
