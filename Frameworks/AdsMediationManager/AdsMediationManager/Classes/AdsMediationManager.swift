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
import MTGSDK
import VungleAdsSDK

open class AdsMediationManager: NSObject {
    
    //Instance
    public static let shared: AdsMediationManager = AdsMediationManager()
    
    //Inter
    var interAdsManagers: [String: InterAdsManager] = [:]
    var interAdsShowTime: Date?
    var isShowingFullAds = false

    //Reward
    var rewardAdsManagers: [String: RewardAdsManager] = [:]
    
    //Native
    var nativeAdsManagers: [String: NativeAdsManager] = [:]
    
    //Open
    var openAdsManagers: [String: OpenAdsManager] = [:]
    var openAdsShowTime: Date?
}
//MARK: -- Check and preload
extension AdsMediationManager{
    
    public func preLoadAllAdsIfNeed(){
        let adsUnitJson = ConfigAdsManager.shared.getAdsUnitsJson()
        for itemKey in adsUnitJson.keys{
            if let datas = adsUnitJson[itemKey] as? [[String: Any]]{
                if datas.count > 0{
                    let unit = AdsUnit.objInfo(datas[0])
                    preloadAds(unit, unitKey: itemKey)
                }
            }
        }
    }
    
    private func preloadAds(_ unit: AdsUnit, unitKey: String){
        if unit.allowPreLoad{
            if unit.ads_type == "inter"{
                loadInterAdsUnit(unitKey, handleLoadingAds: nil)
            }else if unit.ads_type == "native"{
                loadNativeAdsUnit(unitKey, handleDidReceiveAd: nil)
            }else if unit.ads_type == "reward"{
                loadRewardAdsUnit(unitKey, handleLoadingAds: nil)
            }else if unit.ads_type == "open"{
                loadOpenAdsUnit(unitKey, handleLoadingAds: nil)
            }
        }
    }
    
    public func initAdsSDK(handleInit: ((Bool) -> Void)?) {
       
        MTGSDK.sharedInstance().consentStatus = true
        MTGSDK.sharedInstance().doNotTrackStatus = false
        
        ALPrivacySettings.setHasUserConsent(true)
        ALPrivacySettings.setIsAgeRestrictedUser(false)
        ALPrivacySettings.setDoNotSell(false)
        
        VunglePrivacySettings.setGDPRStatus(true)
        VunglePrivacySettings.setGDPRMessageVersion("v2.4.0")
        VunglePrivacySettings.setCCPAStatus(true)
        
        GADMobileAds.sharedInstance().start { status in
            print(status)
            handleInit?(true)
        }
        let applovinKey = "KzhQuVbsma9BTIxZCGxKdTvmegVnTF4uCmI4Gvx0T5ByN7VaNRw_-qmdUFP2UTwgEDmV6hVanhW9p0kASd9RSw"
        
        let initConfig = ALSdkInitializationConfiguration(sdkKey: applovinKey){ builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        ALSdk.shared().initialize(with: initConfig){ sdkConfig in
            //Start loading ads
            print("ALSdk Init OK")
        }
    }
}

//MARK: -- Inter
extension AdsMediationManager{
    
    private func loadInterAdsUnit(_ unitKey: String, handleLoadingAds: ((Bool) -> Void)?){
        interAdsManager(unitKey).loadInterstitialAds(unitKey,handleLoadingAds: handleLoadingAds)
    }
    
    public func loadInterAds(_ placementKey: String, handleLoadingAds: ((Bool) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        if !placement.enable{
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        interAdsManager(placement.ads_unit).loadInterstitialAds(placement.ads_unit,handleLoadingAds: handleLoadingAds)
    }
    
    public func showInterAds(_ placementKey: String, viewController: UIViewController, handleInterAdDidDismiss: ((Bool) -> Void)?){

        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleInterAdDidDismiss?(false)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleInterAdDidDismiss?(false)
            return
        }
        
        var needShowAds = false
        let isDirect = placement.direct
        
        if interAdsShowTime == nil || isDirect{
            needShowAds = true
        }else{
            let time = Date().timeIntervalSince(interAdsShowTime!)
            let timeToShowAds = ConfigAdsManager.shared.getAdsInterval()
            if time >=  TimeInterval(timeToShowAds){
                needShowAds = true
            }
        }
        
        if needShowAds{
            isShowingFullAds = true
            if interAdsManager(placement.ads_unit).isAvaiableFullAds(){
                interAdsManager(placement.ads_unit).showAds(viewController) { result in
                    if result{
                        self.interAdsShowTime = Date()
                    }
                    self.isShowingFullAds = false
                    handleInterAdDidDismiss?(result)
                }
            }else{
                interAdsManager("inter_backup").showAds(viewController) { result in
                    if result{
                        self.interAdsShowTime = Date()
                    }
                    self.isShowingFullAds = false
                    handleInterAdDidDismiss?(result)
                }
                loadInterAdsUnit(placement.ads_unit, handleLoadingAds: nil)
            }
            
        }else{
            print("Not enough time interval: \(ConfigAdsManager.shared.getAdsInterval())")
            handleInterAdDidDismiss?(false)
        }
    }
    
    public func isReadyInterAds(_ placementKey: String) -> Bool{
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            return false
        }
        return interAdsManager(placement.ads_unit).isAvaiableFullAds()
    }
    
    private func interAdsManager(_ key: String) -> InterAdsManager{
        if let interAdsManager = interAdsManagers[key]{
            return interAdsManager
        }
        let inter = InterAdsManager()
        interAdsManagers[key] = inter
        return inter
    } 
}

//MARK: -- Native
extension AdsMediationManager{
    
    private func loadNativeAdsUnit(_ unitKey: String, handleDidReceiveAd: ((GADNativeAd?) -> Void)?){
        nativeAdsManager(unitKey).loadNativeAds(unitKey, handleDidReceiveAd: handleDidReceiveAd)
    }
    
    public func loadNativeAds(_ placementKey: String, handleDidReceiveAd: ((GADNativeAd?) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleDidReceiveAd?(nil)
            return
        }
        if !placement.enable{
            print("Placement Not avaiable")
            handleDidReceiveAd?(nil)
            return
        }
        nativeAdsManager(placement.ads_unit).loadNativeAds(placement.ads_unit, handleDidReceiveAd: handleDidReceiveAd)
    }
    
    public func getNativeAdsFromCache(_ placementKey: String) -> GADNativeAd?{
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            return nil
        }
        if !placement.enable{
            print("Placement Not avaiable")
            return nil
        }
        return nativeAdsManagers[placement.ads_unit]?.getAdmobNativeAds()
    }

    private func nativeAdsManager(_ key: String) -> NativeAdsManager{
        if let nativeAdsManager = nativeAdsManagers[key]{
            return nativeAdsManager
        }
        let nativeManager = NativeAdsManager()
        nativeAdsManagers[key] = nativeManager
        return nativeManager
    }
}


extension AdsMediationManager{
    
    private func loadRewardAdsUnit(_ key: String, handleLoadingAds: ((Bool) -> Void)?){
        rewardAdsManager(key).loadRewardAds(key, handleLoadingAds: handleLoadingAds)
    }
    
    public func loadRewardAds(_ placementKey: String, handleLoadingAds: ((Bool) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        rewardAdsManager(placement.ads_unit).loadRewardAds(placement.ads_unit, handleLoadingAds: handleLoadingAds)
    }
    
    public func showRewardAds(_ placementKey: String, viewController: UIViewController, handleInterAdDidDismiss: ((Bool) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleInterAdDidDismiss?(false)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleInterAdDidDismiss?(false)
            return
        }
        rewardAdsManager(placement.ads_unit).showRewardAds(viewController, handleAdDidDismiss: handleInterAdDidDismiss)
    }
    
    public func isReadyRewardAds(_ placementKey: String) -> Bool{
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            return false
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            return false
        }
        return rewardAdsManager(placement.ads_unit).isReadyAds()
    }
    
    private func rewardAdsManager(_ key: String) -> RewardAdsManager{
        if let rewardAdsManager = rewardAdsManagers[key]{
            return rewardAdsManager
        }
        let rewardAdsManager = RewardAdsManager()
        rewardAdsManagers[key] = rewardAdsManager
        return rewardAdsManager
    }
}

//MARK: -- Open
extension AdsMediationManager{
    
    private func loadOpenAdsUnit(_ key: String, handleLoadingAds: ((Bool) -> Void)?){
        openAdsManager(key).checkLoadOpenAds(key, handleLoadingAds: handleLoadingAds)
    }
    
    public func loadOpen(_ placementKey: String, handleLoadingAds: ((Bool) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleLoadingAds?(false)
            return
        }
        openAdsManager(placement.ads_unit).checkLoadOpenAds(placement.ads_unit, handleLoadingAds: handleLoadingAds)
    }
    
    public func showOpenAds(_ placementKey: String, viewController: UIViewController, handleAdDidDismiss: ((Bool) -> Void)?){
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleAdDidDismiss?(false)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleAdDidDismiss?(false)
            return
        }
        
        var needShowAds = false
        let isDirect = placement.direct
        
        if openAdsShowTime == nil || isDirect{
            needShowAds = true
        }else{
            let time = Date().timeIntervalSince(openAdsShowTime!)
            let timeToShowAds = ConfigAdsManager.shared.getOpenInterval()
            if time >=  TimeInterval(timeToShowAds){
                needShowAds = true
            }
        }
        
        if needShowAds{
            if openAdsManager(placement.ads_unit).isAvaiableAds(){
                openAdsManager(placement.ads_unit).showAds(viewController) { result in
                    if result{
                        self.openAdsShowTime = Date()
                    }
                    handleAdDidDismiss?(result)
                }
            }else{
                openAdsManager("open_backup").showAds(viewController) { result in
                    if result{
                        self.openAdsShowTime = Date()
                    }
                    handleAdDidDismiss?(result)
                }
                loadOpenAdsUnit(placement.ads_unit, handleLoadingAds: nil)
            }
        }else{
            print("Not enough time open interval: \(ConfigAdsManager.shared.getOpenInterval())")
            handleAdDidDismiss?(false)
        }
    }
    
    public func isReadyOpen(_ placementKey: String) -> Bool{
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            return false
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            return false
        }
        return openAdsManager(placement.ads_unit).isAvaiableAds()
    }
    
    private func openAdsManager(_ key: String) -> OpenAdsManager{
        if let openAdsManager = openAdsManagers[key]{
            return openAdsManager
        }
        let open = OpenAdsManager()
        openAdsManagers[key] = open
        return open
    }
}
