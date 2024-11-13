//
//  AppsFlyerAdRevenueTracking.swift
//  AdsMediationManager
//
//  Created by Tung Vu Thien on 16/04/2024.
//

import Foundation
import GoogleMobileAds
import AppsFlyerAdRevenue

class AppsFlyerAdRevenueTracking {
    enum AdType {
        case inter(GADInterstitialAd)
        case native(GADNativeAd, adUnit: String)
        case reward(GADRewardedAd)
        case banner(GADBannerView)
        case open(GADAppOpenAd, adUnit: String)
    }
    
    static var shared = AppsFlyerAdRevenueTracking()
    
    func track(adType: AdType) {
        switch adType {
        case .inter(let interstitialAd):
            interstitialAd.paidEventHandler = { adValue in
                
                let eventRevenue = (adValue.value as Decimal)
                let revenueCurrency = adValue.currencyCode
                let adUnitId = interstitialAd.adUnitID
                let monetizationNetwork = interstitialAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "admob"
                
                let additionalParameters: [AnyHashable: Any] = [kAppsFlyerAdRevenueAdUnit : adUnitId,
                                                                kAppsFlyerAdRevenueAdType : "InterstitialAd"]
                
                logAdRevenue(monetizationNetwork: monetizationNetwork,
                             eventRevenue: eventRevenue,
                             revenueCurrency: revenueCurrency,
                             additionalParameters: additionalParameters)
            }
        case .native(let (nativeAd, adUnit)):
            nativeAd.paidEventHandler = { adValue in
                let eventRevenue = (adValue.value as Decimal)
                let revenueCurrency = adValue.currencyCode
                let adUnitId = adUnit
                
                let monetizationNetwork = nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "admob"
                
                let additionalParameters: [AnyHashable: Any] = [kAppsFlyerAdRevenueAdUnit : adUnitId,
                                                                kAppsFlyerAdRevenueAdType : "NativeAd"]
                
                logAdRevenue(monetizationNetwork: monetizationNetwork,
                             eventRevenue: eventRevenue,
                             revenueCurrency: revenueCurrency,
                             additionalParameters: [:])
                
            }
        case .reward(let rewardedAd):
            rewardedAd.paidEventHandler = { adValue in
                let eventRevenue = (adValue.value as Decimal)
                let revenueCurrency = adValue.currencyCode
                let adUnitId = rewardedAd.adUnitID
                let monetizationNetwork = rewardedAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "admob"
                
                let additionalParameters: [AnyHashable: Any] = [kAppsFlyerAdRevenueAdUnit : adUnitId,
                                                                kAppsFlyerAdRevenueAdType : "RewarededAd"]
                
                logAdRevenue(monetizationNetwork: monetizationNetwork,
                             eventRevenue: eventRevenue,
                             revenueCurrency: revenueCurrency,
                             additionalParameters: additionalParameters)
            }
        case .banner(let bannerAd):
            bannerAd.paidEventHandler = { adValue in
                let eventRevenue = (adValue.value as Decimal)
                let revenueCurrency = adValue.currencyCode
                let adUnitId = bannerAd.adUnitID
                let monetizationNetwork = bannerAd.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "admob"
                
                let additionalParameters: [AnyHashable: Any] = [kAppsFlyerAdRevenueAdUnit : adUnitId,
                                                                kAppsFlyerAdRevenueAdType : "BannerAd"]
                
                logAdRevenue(monetizationNetwork: monetizationNetwork,
                             eventRevenue: eventRevenue,
                             revenueCurrency: revenueCurrency,
                             additionalParameters: additionalParameters)
            }
        case .open(let (openAd, adUnit)):
            openAd.paidEventHandler = { adValue in
                let eventRevenue = (adValue.value as Decimal)
                let revenueCurrency = adValue.currencyCode
                let adUnitId = adUnit
                let monetizationNetwork = openAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "admob"
                
                let additionalParameters: [AnyHashable: Any] = [kAppsFlyerAdRevenueAdUnit : adUnitId,
                                                                kAppsFlyerAdRevenueAdType : "OpenAd"]
                
                logAdRevenue(monetizationNetwork: monetizationNetwork,
                             eventRevenue: eventRevenue,
                             revenueCurrency: revenueCurrency,
                             additionalParameters: additionalParameters)
            }
        }
        
        func logAdRevenue(monetizationNetwork: String,
                          eventRevenue: Decimal,
                          revenueCurrency: String,
                          additionalParameters: [AnyHashable: Any]) {
            debugPrint("✅ logAdRevenue:", adType, "\(eventRevenue) \(revenueCurrency)")
            
            AppsFlyerAdRevenue.shared().logAdRevenue(
                monetizationNetwork: monetizationNetwork,
                mediationNetwork: MediationNetworkType.googleAdMob,
                eventRevenue: eventRevenue as NSNumber,
                revenueCurrency: revenueCurrency,
                additionalParameters: additionalParameters)
        }
    }
}
