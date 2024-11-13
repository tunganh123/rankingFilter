//
//  BannerMediationManager.swift
//  AdsMediationManager
//
//  Created by Admin on 13/07/2023.
//

import UIKit
import GoogleMobileAds

open class BannerAdsManager: NSObject {
    
    let timeForDelayLoad = 5
    var loadTime: Date?
    
    public var bannerHeight: CGFloat = 0.0
    var currentAdsIndex = 0
    var adsUnits: [AdsUnit] = []
    var placement: AdsPlacement!
    
    public var isAllowCollapsible = true
    
    public var handleDidReceiveAd: ((CGFloat) -> Void)?
    public var handleDidLoadFailAd: ((CGFloat) -> Void)?
    public var isAdaptiveBannerAdSize = true
    
    public func removeBanner(_key: String, contentView: UIView){
        if let bannerView = contentView.viewWithTag(1231) as? GADBannerView{
            bannerView.isHidden = true
            bannerView.removeFromSuperview()
        }
    }
    
    public func loadBanner(_ placementKey: String, contentView: UIView, rootVC: UIViewController) {
        
        guard let placement = ConfigAdsManager.shared.getPlacement(placementKey) else {
            print("Placement Not avaiable")
            handleDidLoadFailAd?(0)
            return
        }
        
        if !placement.enable{
            print("Placement Not avaiable")
            handleDidLoadFailAd?(0)
            return
        }
        
        self.placement = placement
        
        let ads = ConfigAdsManager.shared.getAdsUnits(placement.ads_unit)
        adsUnits = ads.filter({ item in
            return item.enable
        })
        
        if PaymentManager.shared.isPremium() {
            handleDidLoadFailAd?(0)
            return
        }
        
        if adsUnits.count == 0{
            handleDidLoadFailAd?(0)
            return
        }
        
        if let bannerTime = loadTime{
            let time = Date().timeIntervalSince(bannerTime)
            if time <=  TimeInterval(timeForDelayLoad) {
                print("Can not load banner \(timeForDelayLoad)s")
                return
            }
        }
        
        currentAdsIndex = 0
        if let bannerView = contentView.viewWithTag(1231) as? GADBannerView{
            loadBanner(bannerView, rootVC: rootVC)
        }else{
            let gadBanner = GADBannerView(adSize: GADAdSizeBanner)
            if placement.position == "top"{
                addBannerViewToTop(contentView, bannerView: gadBanner)
            }else{
                addBannerViewToBottom(contentView, bannerView: gadBanner)
            }
            gadBanner.tag = 1231
            contentView.addSubview(gadBanner)
            loadBanner(gadBanner, rootVC: rootVC)
        }
    }
    
    private func addBannerViewToTop(_ contentView: UIView, bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerView)
        contentView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: contentView.safeAreaLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: contentView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    private func addBannerViewToBottom(_ contentView: UIView, bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerView)
        contentView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: contentView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: contentView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}

extension BannerAdsManager {
    
    private func loadBanner(_ banner: GADBannerView, rootVC: UIViewController) {
        
        if PaymentManager.shared.isPremium() {
            banner.isHidden = true
            return
        }

        if adsUnits.count == 0 {
            return
        }
        
        if currentAdsIndex >= adsUnits.count {
            currentAdsIndex = 0
        }
        
        loadTime = Date()
        
        let bannerKey = adsUnits[currentAdsIndex].unitId
        print("Load banner key: \(bannerKey)")
        loadBanner(banner, rootVC: rootVC, adsUnit: adsUnits[currentAdsIndex])
    }

    private func loadBanner(_ banner: GADBannerView, rootVC: UIViewController, adsUnit: AdsUnit) {
        banner.isHidden = false
        banner.adUnitID = adsUnit.unitId
        banner.delegate = self
        banner.rootViewController = rootVC
        
        if isAdaptiveBannerAdSize{
            let viewWidth = UIScreen.main.bounds.size.width
            banner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        }

        let request = GADRequest()
        adsUnit.printInfo()
        if placement.collapsible && isAllowCollapsible {
            let extras = GADExtras.init()
            if placement.position == "top" {
                extras.additionalParameters = ["collapsible": "top"]
            } else {
                extras.additionalParameters = ["collapsible": "bottom"]
            }
            request.register(extras)
        }
        banner.load(request)
    }
}

extension BannerAdsManager: GADBannerViewDelegate {
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("BannerViewDidReceiveAd: \(bannerView.bounds.size)")
        if PaymentManager.shared.isPremium() {
            bannerView.isHidden = true
        } else {
            bannerView.isHidden = false
        }
        bannerHeight = bannerView.bounds.size.height
        handleDidReceiveAd?(bannerView.bounds.size.height)
        AppsFlyerAdRevenueTracking.shared.track(adType: .banner(bannerView))
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("didFailToReceiveAdWithError bannerView: \(error.localizedDescription)")
        bannerView.isHidden = true
        currentAdsIndex = currentAdsIndex + 1
        if currentAdsIndex < adsUnits.count{
            if let rootVC = bannerView.rootViewController {
                bannerView.delegate = self
                self.loadBanner(bannerView, rootVC: rootVC)
            }
        } else {
            currentAdsIndex = 0
            handleDidLoadFailAd?(0)
        }
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
