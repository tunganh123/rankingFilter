//
//  RateManager.swift
//  AdsMediationManager
//
//  Created by Admin on 10/11/2023.
//

import Foundation
import StoreKit

open class RateManager {
    
    public static let shared: RateManager = RateManager()
    
    var counterEventRateApp = 0
    let numberEventRateApp = 3
    var isShowedRateApp = false
    
    public func logEventToShowRateApp(){
        counterEventRateApp = counterEventRateApp + 1
        if counterEventRateApp % numberEventRateApp == 0{
            if !isShowedRateApp{
                isShowedRateApp = true
                showRate()
            }
        }
    }
    
    public func showRate(){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
    
}
