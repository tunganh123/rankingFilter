//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import GoogleMobileAds
import AppLovinSDK

open class OpenAdsManager: NSObject {
    
    public static let shared: OpenAdsManager = OpenAdsManager()

    public var isLoadingOpenAds = false

    var appOpenAds: GADAppOpenAd?
    var appOpenMax: MAAppOpenAd?

    var adsLoadTime: Date = Date()
    var currentAdsIndex = 0
    var adsUnits: [AdsUnit] = []
    
    var handleAdDidDismiss: ((Bool) -> Void)?
    var handleLoadingAds: ((Bool) -> Void)?
}

extension OpenAdsManager{
    
    public func isAvaiableAds() -> Bool{
        if appOpenAds != nil{
            return true
        }
        return false
    }
    
    public func checkLoadOpenAds(_ key: String, handleLoadingAds: ((Bool) -> Void)?){
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
        if appOpenAds != nil && timeLessThan4HoursAgo(){
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
        }else{
            loadOpenAds()
        }
    }
        
    public func showAds(_ viewControlelr: UIViewController, handleAdDidDismiss: ((Bool) -> Void)?){

        self.handleAdDidDismiss = handleAdDidDismiss
        
        if PaymentManager.shared.isPremium(){
            self.handleAdDidDismiss?(false)
            self.handleAdDidDismiss = nil
            return
        }
        
        if !ConfigAdsManager.shared.getAdsEnable(){
            self.handleAdDidDismiss?(false)
            self.handleAdDidDismiss = nil
            return
        }
        
        if appOpenAds != nil && timeLessThan4HoursAgo(){
            if AdsMediationManager.shared.isShowingFullAds{
                print("Not show ads in inter ads!")
                self.handleAdDidDismiss?(false)
                self.handleAdDidDismiss = nil
                return
            }
            appOpenAds?.present(fromRootViewController: viewControlelr)
        }else{
            if appOpenMax?.isReady ?? false{
                appOpenMax?.show()
            }else{
                loadOpenAds()
                self.handleAdDidDismiss?(false)
                self.handleAdDidDismiss = nil
            }
        }
    }
}

extension OpenAdsManager{
    
    private func loadOpenAds(){
        
        if PaymentManager.shared.isPremium(){
            return
        }
        
        if !ConfigAdsManager.shared.getAdsEnable(){
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
            return
        }
        
        if adsUnits.count == 0{
            return
        }
        appOpenAds = nil
        if currentAdsIndex >= adsUnits.count{
            currentAdsIndex = 0
        }

        let openKey = adsUnits[currentAdsIndex].unitId
        print("Loading open ads with key: \(openKey)")
        isLoadingOpenAds = true
        if adsUnits[currentAdsIndex].network == "admob"{
            loadOpenAdsWithKey(openAdsKey: openKey)
        }else if adsUnits[currentAdsIndex].network == "applovin"{
            loadOpenMaxWithKey(openAdsKey: openKey)
        }else{
            self.currentAdsIndex = self.currentAdsIndex + 1
            if self.currentAdsIndex < self.adsUnits.count{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadOpenAds()
                }
            }else{
                self.isLoadingOpenAds = false
                self.currentAdsIndex = 0
                self.handleLoadingAds?(false)
                self.handleLoadingAds = nil
            }
        }
    }
    
    private func loadOpenAdsWithKey(openAdsKey: String){
        GADAppOpenAd.load(withAdUnitID: openAdsKey, request: GADRequest()) { [unowned self] openAds, error in
            if let error = error{
                print("Load open ads error \(error.localizedDescription)")
                self.currentAdsIndex = self.currentAdsIndex + 1
                if self.currentAdsIndex < self.adsUnits.count{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.loadOpenAds()
                    }
                }else{
                    print("Load open ads error \(error.localizedDescription)")
                    self.isLoadingOpenAds = false
                    self.currentAdsIndex = 0
                    self.handleLoadingAds?(false)
                    self.handleLoadingAds = nil
                }
            }else{
                print("Load open ads OK")
                self.appOpenAds = openAds
                self.appOpenAds?.fullScreenContentDelegate = self
                self.adsLoadTime = Date()
                self.isLoadingOpenAds = false
                self.handleLoadingAds?(true)
                self.handleLoadingAds = nil
                if let appOpenAds = self.appOpenAds {
                    AppsFlyerAdRevenueTracking.shared.track(adType: .open(appOpenAds, adUnit: openAdsKey))
                }
            }
        }
    }
    
    private func loadOpenMaxWithKey(openAdsKey: String){
        appOpenMax = MAAppOpenAd(adUnitIdentifier: openAdsKey)
        appOpenMax?.delegate = self
        appOpenMax?.revenueDelegate = self
        appOpenMax?.load()
    }
    
    private func timeLessThan4HoursAgo() -> Bool{
        let time = Date().timeIntervalSince(adsLoadTime)
        let seconds = 3600.0
        let ratioTime = time / seconds
        if ratioTime < 4.0{
            return true
        }else{
            return false
        }
    }
}

extension OpenAdsManager : GADFullScreenContentDelegate{
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        loadOpenAds()
        handleAdDidDismiss?(false)
        handleAdDidDismiss = nil
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        currentAdsIndex = 0
        loadOpenAds()
        handleAdDidDismiss?(true)
        handleAdDidDismiss = nil
    }
}

extension OpenAdsManager:MAAdViewAdDelegate{
    public func didExpand(_ ad: MAAd) {
        
    }
    
    public func didCollapse(_ ad: MAAd) {
        
    }
    
    public func didLoad(_ ad: MAAd) {
        print("Load open ads OK")
        self.adsLoadTime = Date()
        self.isLoadingOpenAds = false
        self.handleLoadingAds?(true)
        self.handleLoadingAds = nil
//        if let appOpenAds = self.appOpenAds {
//            AppsFlyerAdRevenueTracking.shared.track(adType: .open(appOpenAds, adUnit: openAdsKey))
//        }
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("Load open ads max error \(error.description)")
        self.currentAdsIndex = self.currentAdsIndex + 1
        if self.currentAdsIndex < self.adsUnits.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadOpenAds()
            }
        }else{
            print("Load open ads max error \(error.description)")
            self.isLoadingOpenAds = false
            self.currentAdsIndex = 0
            self.handleLoadingAds?(false)
            self.handleLoadingAds = nil
        }
    }
    
    public func didDisplay(_ ad: MAAd) {
        
    }
    
    public func didHide(_ ad: MAAd) {
        print("didHide")
        currentAdsIndex = 0
        loadOpenAds()
        handleAdDidDismiss?(true)
        handleAdDidDismiss = nil
    }
    
    public func didClick(_ ad: MAAd) {
        
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("didFail(toDisplay")
        loadOpenAds()
        handleAdDidDismiss?(false)
        handleAdDidDismiss = nil
    }
}

extension OpenAdsManager:MAAdRevenueDelegate{
    public func didPayRevenue(for ad: MAAd) {
        
    }
}
