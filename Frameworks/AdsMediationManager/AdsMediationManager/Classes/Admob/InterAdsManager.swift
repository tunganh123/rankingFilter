//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import GoogleMobileAds
import StoreKit
import AppLovinSDK

open class InterAdsManager: NSObject {
        
    var interstitialAdmob: GADInterstitialAd?
    var interstitialMax:  MAInterstitialAd?

    var adsUnits: [AdsUnit] = []
    
    var currentAdsIndex = 0
    var isLoadingInterAds = false

    var handleAdDidDismiss: ((Bool) -> Void)?
    var handleLoadingAds: ((Bool) -> Void)?

    public override init() {
        super.init()
    }
    
    func rootViewController() -> UIViewController{
        return (UIApplication.shared.windows.first?.rootViewController)!
    }
}

extension InterAdsManager{
    
    public func isAvaiableFullAds() -> Bool{
        
        if interstitialAdmob != nil{
            return true
        }
        
        if interstitialMax?.isReady ?? false{
            return true
        }
        
        return false
    }

    public func loadInterstitialAds(_ key: String, handleLoadingAds: ((Bool) -> Void)?){
        self.handleLoadingAds = handleLoadingAds
        let ads = ConfigAdsManager.shared.getAdsUnits(key)
        adsUnits = ads.filter({ item in
            return item.enable
        })
        if PaymentManager.shared.isPremium(){
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
            return
        }
        
        if adsUnits.count == 0{
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
            return
        }
        currentAdsIndex = 0
        loadInterstitialAds()
    }
    
    public func showAds(_ viewControlelr: UIViewController, handleAdDidDismiss: ((Bool) -> Void)?){
        
        self.handleAdDidDismiss = handleAdDidDismiss
        
        if PaymentManager.shared.isPremium(){
            self.handleAdDidDismiss?(false)
            return
        }
        
        if let ad = self.interstitialAdmob {
            ad.present(fromRootViewController: viewControlelr)
        } else {
            if interstitialMax?.isReady ?? false{
                interstitialMax?.show()
            }else{
                if isLoadingInterAds{
                    print("Ads is loading...")
                }else{
                    print("Ad wasn't ready")
                    currentAdsIndex = 0
                    loadInterstitialAds()
                }
                self.handleAdDidDismiss?(false)
            }
        }
    }
}

extension InterAdsManager{
    
    private func loadInterstitialAds(){
        if PaymentManager.shared.isPremium(){
            return
        }
        
        if adsUnits.count == 0{
            return
        }
        
        if currentAdsIndex >= adsUnits.count{
            currentAdsIndex = 0
        }
        
        let fullKey = adsUnits[currentAdsIndex].unitId
        isLoadingInterAds = true
        
        if adsUnits[currentAdsIndex].network == "admob"{
            loadAdmobMediationInstitial(fullKey: fullKey)
        }else if adsUnits[currentAdsIndex].network == "applovin"{
            loadMaxMediationInstitial(fullKey: fullKey)
        }else{
            self.currentAdsIndex = self.currentAdsIndex + 1
            if self.currentAdsIndex < self.adsUnits.count{
                self.loadInterstitialAds()
            }else{
                self.isLoadingInterAds = false
                self.currentAdsIndex = 0
                self.handleLoadingAds?(false)
                self.handleLoadingAds = nil
            }
        }
    }
    
    private func loadAdmobMediationInstitial(fullKey: String){
        print("Load admob mediation inter key: \(fullKey)")
        self.interstitialAdmob = nil
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: fullKey, request: request) { (ad, error) in
            if let error = error {
                print("Load admob inter error: \(error.localizedDescription)")
                self.currentAdsIndex = self.currentAdsIndex + 1
                if self.currentAdsIndex < self.adsUnits.count{
                    self.loadInterstitialAds()
                }else{
                    self.isLoadingInterAds = false
                    self.currentAdsIndex = 0
                    self.handleLoadingAds?(false)
                    self.handleLoadingAds = nil
                }
                return
            }
            print("Load admob inter OK")
            self.isLoadingInterAds = false
            self.interstitialAdmob = ad
            self.interstitialAdmob?.fullScreenContentDelegate = self
            self.handleLoadingAds?(true)
            self.handleLoadingAds = nil
            
            if let interstitialAdmob = self.interstitialAdmob {
                AppsFlyerAdRevenueTracking.shared.track(adType: .inter(interstitialAdmob))
            }
        }
    }
    
    private func loadMaxMediationInstitial(fullKey: String){
        print("Load max mediation inter key: \(fullKey)")
        interstitialMax = MAInterstitialAd(adUnitIdentifier: fullKey)
        interstitialMax?.delegate = self
        interstitialMax?.revenueDelegate = self
        interstitialMax?.load()
    }
}

extension InterAdsManager: GADFullScreenContentDelegate{
        
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.handleAdDidDismiss?(false)
            self?.currentAdsIndex = 0
            self?.loadInterstitialAds()
        }
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            NotificationCenter.default.post(name: NotificationbAdsEnd, object: nil)
            self?.handleAdDidDismiss?(true)
            self?.currentAdsIndex = 0
            self?.loadInterstitialAds()
        }
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adWillPresentFullScreenContent")
        NotificationCenter.default.post(name: NotificationbAdsStart, object: nil)
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("adDidRecordClick")
    }
}

extension InterAdsManager: MAAdRevenueDelegate{
    
    public func didPayRevenue(for ad: MAAd) {
        logCallback()
    }
}

extension InterAdsManager: MAAdViewAdDelegate{
    public func didExpand(_ ad: MAAd) {
        logCallback()
    }
    
    public func didCollapse(_ ad: MAAd) {
        logCallback()
    }
  
    public func didLoad(_ ad: MAAd) {
        logCallback()
        print("Load max inter OK")
        self.isLoadingInterAds = false
        self.handleLoadingAds?(true)
        self.handleLoadingAds = nil
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        logCallback()
        print("Load max inter error: \(error.description)")
        self.currentAdsIndex = self.currentAdsIndex + 1
        if self.currentAdsIndex < self.adsUnits.count{
            self.loadInterstitialAds()
        }else{
            self.isLoadingInterAds = false
            self.currentAdsIndex = 0
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
        }
    }
    
    public func didDisplay(_ ad: MAAd) {
        logCallback()
        NotificationCenter.default.post(name: NotificationbAdsStart, object: nil)
    }
    
    public func didHide(_ ad: MAAd) {
        logCallback()
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            NotificationCenter.default.post(name: NotificationbAdsEnd, object: nil)
            self?.handleAdDidDismiss?(true)
            self?.currentAdsIndex = 0
            self?.loadInterstitialAds()
        }
    }
    
    public func didClick(_ ad: MAAd) {
        logCallback()
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        logCallback()
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.handleAdDidDismiss?(false)
            self?.currentAdsIndex = 0
            self?.loadInterstitialAds()
        }
    }
}


public let NotificationbAdsEnd = Notification.Name("notificationbAdsEnd")
public let NotificationbAdsStart = Notification.Name("notificationbAdsStart")

internal func logCallback(functionName: String = #function){
    print(functionName)
}
