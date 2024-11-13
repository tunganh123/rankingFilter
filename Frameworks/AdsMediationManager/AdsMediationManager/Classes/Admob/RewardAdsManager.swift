//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import GoogleMobileAds

open class RewardAdsManager: NSObject {
        
    public var rewardedAd: GADRewardedAd?
    var adsUnits: [AdsUnit] = []
    var currentAdsIndex = 0
    var isLoadingRewardAds = true

    var handleAdDidDismiss: ((Bool) -> Void)?
    var handleLoadingAds: ((Bool) -> Void)?
    var isRewared = false
    
    public override init() {
        super.init()
    }
}

extension RewardAdsManager{
    
    public func isReadyAds() -> Bool{
        if rewardedAd == nil{
            return false
        }
        return true
    }
    
    public func loadRewardAds(_ key: String, handleLoadingAds: ((Bool) -> Void)?){
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
        loadRewardedAds(completion: handleLoadingAds)
    }

    public func showRewardAds(_ viewController: UIViewController, handleAdDidDismiss: ((Bool) -> Void)?) {
        isRewared = false
        self.handleAdDidDismiss = handleAdDidDismiss
        if let ad = rewardedAd {
            ad.present(fromRootViewController: viewController) {
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                self.isRewared = true
            }
        } else {
            print("Ad wasn't ready")
            handleAdDidDismiss?(false)
        }
    }
}

extension RewardAdsManager{
    
    private func loadRewardedAds(completion: ((Bool) -> Void)?) {

        if rewardedAd != nil {
            completion?(true)
        }

        if adsUnits.count == 0{
            completion?(false)
            return
        }
        if currentAdsIndex >= adsUnits.count{
            currentAdsIndex = 0
        }
        
        let videoKey = adsUnits[currentAdsIndex].unitId
        isLoadingRewardAds = true
        loadRewardedAds(videoKey, completion: completion)
    }
    
    private func loadRewardedAds(_ rewardKey: String, completion: ((Bool) -> Void)?){
        print("Loading reward ads with key: \(rewardKey)")
        self.rewardedAd = nil
        GADRewardedAd.load(withAdUnitID: rewardKey, request: GADRequest()) { [self] ads, error in
            if let error = error {
                print("Loading reward ads with key: \(rewardKey) Error: \(error.localizedDescription).")
                self.currentAdsIndex = self.currentAdsIndex + 1
                if self.currentAdsIndex < self.adsUnits.count{
                    self.loadRewardedAds(completion: completion)
                }else{
                    self.isLoadingRewardAds = false
                    self.currentAdsIndex = 0
                    completion?(false)
                }
            }else{
                print("Loading reward ads with key: \(rewardKey) OK.")
                rewardedAd = ads
                rewardedAd?.fullScreenContentDelegate = self
                completion?(true)
                if let rewardedAd = self.rewardedAd {
                    AppsFlyerAdRevenueTracking.shared.track(adType: .reward(rewardedAd))
                }
            }
        }
    }
}

extension RewardAdsManager: GADFullScreenContentDelegate{
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        handleAdDidDismiss?(isRewared)
        currentAdsIndex = 0
        loadRewardedAds(completion: nil)
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        handleAdDidDismiss?(isRewared)
        currentAdsIndex = 0
        loadRewardedAds(completion: nil)
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adWillPresentFullScreenContent")
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("adDidRecordClick")
    }
}
