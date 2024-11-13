//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import FirebaseAnalytics
import AppsFlyerLib

open class EventManager {
    
    public class func logEvent(_ eventName: String, params: [String: Any]? = nil) {
    
        if let params = params {
            print("Event name: \(eventName) param: \(params)")
            AppsFlyerLib.shared().logEvent(eventName, withValues: params)
            Analytics.logEvent(eventName, parameters: params)
        } else {
            print("Event name: \(eventName)")
            AppsFlyerLib.shared().logEvent(eventName, withValues: nil)
            Analytics.logEvent(eventName, parameters: nil)
        }
    }
}
