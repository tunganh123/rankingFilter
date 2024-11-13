//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import GoogleMobileAds

open class NativeAdsManager: NSObject {
    
    public static let shared: NativeAdsManager = NativeAdsManager()

    var adsUnits: [AdsUnit] = []
    var currentAdsIndex = 0
    var isLoadingNativeAds = true

    var nativeAds: [GADNativeAd] = []
    var adLoader: GADAdLoader!
    
    var handleDidReceiveAd: ((GADNativeAd?) -> Void)?

    func rootViewController() -> UIViewController {
        return (UIApplication.shared.windows.first?.rootViewController) ?? keyWindow()
    }
    
    func keyWindow() -> UIViewController {
        return UIWindow.key!.rootViewController!
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension NativeAdsManager{
    
    public func loadNativeAds(_ key: String, handleDidReceiveAd: ((GADNativeAd?) -> Void)?){
        self.handleDidReceiveAd = handleDidReceiveAd
        let ads = ConfigAdsManager.shared.getAdsUnits(key)
        adsUnits = ads.filter({ item in
            return item.enable
        })
        
        if PaymentManager.shared.isPremium(){
            self.handleDidReceiveAd?(nil)
            self.handleDidReceiveAd = nil
            return
        }
        
        if adsUnits.count == 0{
            self.handleDidReceiveAd?(nil)
            self.handleDidReceiveAd = nil
            return
        }
        currentAdsIndex = 0
        loadAdmobNativeAds()
    }
    
    public func getAdmobNativeAds() -> GADNativeAd?{
        
        if PaymentManager.shared.isPremium(){
            return nil
        }
        
        if nativeAds.count == 0 {
            return nil
        }
        return nativeAds.last
    }
}

extension NativeAdsManager{
    
    private func loadAdmobNativeAds() {
                
        if PaymentManager.shared.isPremium(){
            return
        }
        
        if adsUnits.count == 0{
            return
        }
        
        if currentAdsIndex >= adsUnits.count{
            currentAdsIndex = 0
        }
        
        let nativeKey = adsUnits[currentAdsIndex].unitId
        print("Loading native ads with key: \(nativeKey)")
        isLoadingNativeAds = true
        loadAdmobNativeWithKey(nativeKey: nativeKey)
    }
    
    private func loadAdmobNativeWithKey(nativeKey: String){
        adLoader = GADAdLoader(
          adUnitID: nativeKey, rootViewController: rootViewController(),
          adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension NativeAdsManager: GADAdLoaderDelegate{
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("didFailToReceiveAdWithError Native: \(error.localizedDescription)")
        self.currentAdsIndex = self.currentAdsIndex + 1
        if self.currentAdsIndex < adsUnits.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadAdmobNativeAds()
            }
        }else{
            self.isLoadingNativeAds = false
            self.currentAdsIndex = 0
            self.handleDidReceiveAd?(nativeAds.last)
        }
    }
}

extension NativeAdsManager: GADNativeAdLoaderDelegate{
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("didReceive nativeAd")
        nativeAds.append(nativeAd)
        self.isLoadingNativeAds = false
        self.handleDidReceiveAd?(nativeAd)
        AppsFlyerAdRevenueTracking.shared.track(adType: .native(nativeAd, adUnit: adLoader.adUnitID))
    }
}
