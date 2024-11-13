//
//  onboardVC.swift
//  DrawLockScreen
//
//  Created by TungAnh on 3/8/24.
//
import AdsMediationManager
import AppLovinSDK
import AVFoundation
import FirebaseRemoteConfig
import GoogleMobileAds
import Localize_Swift
import LouisPod
import MTGSDK
import Qonversion
import SwiftyStoreKit
import UIKit
import UserMessagingPlatform

class onboardVC: UIViewController {
    private var isMobileAdsStartCalled = false
    @IBOutlet var titleLb: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQonversionConfigure()
        // Tracking
      
    }

    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        EventManager.logEvent("splash_need_show_onboarding")
    }

    private func loadQonversionConfigure() {
        Qonversion.shared().remoteConfig { [weak self] remoteConfig, _ in
            if let remoteConfig = remoteConfig {
                if let payload = remoteConfig.payload {
                    InAppType = (payload["inapp_type_v3"] as? Int) ?? 0
                }

                if let value = remoteConfig.experiment {
                    print(value.identifier)
                    print(value.group.identifier)

                    Qonversion.shared().attachUser(toExperiment: value.identifier, groupId: value.group.identifier) { _, _ in
                        print("Thử nghiệm nhóm \(value.identifier) thành công với id: \(value.group.identifier)")
                    }
                }
            } else {
                print(InAppType)
            }
            self?.loadConfig()
        }
    }

    func setupUI() {
        titleLb.text = "Spin Wheel".localized()
        titleLb.font = UIFont(name: "Poppins-SemiBold", size: 35)
    }

    ///////////ADS
    private func loadConfig() {
        ConfigAdsManager.shared.fetchRemoteConfig { [weak self] _ in
            self?.showConsentMessage()
        }
    }

    // Bắt buộc gọi hàm này mới hiện qc dc ở thị trường châu âu
    private func showConsentMessage() {
        let parameters = UMPRequestParameters()

        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
            [weak self] requestConsentError in
            guard let self else { return }

            if let consentError = requestConsentError {
                self.loadAds()
                return print("Error: \(consentError.localizedDescription)")
            }

            UMPConsentForm.loadAndPresentIfRequired(from: self) {
                [weak self] loadAndPresentError in
                guard let self else { return }

                if let consentError = loadAndPresentError {
                    self.loadAds()
                    return print("Error: \(consentError.localizedDescription)")
                }

                // Consent has been gathered.
                if UMPConsentInformation.sharedInstance.canRequestAds {
                    self.loadAds()
                }
            }
        }

        if UMPConsentInformation.sharedInstance.canRequestAds {
            loadAds()
        }
    }

    private func loadAds() {
        guard !isMobileAdsStartCalled else { return }
        isMobileAdsStartCalled = true

        // Init sdk
        AdsMediationManager.shared.initAdsSDK(handleInit: nil)

        // Preload ads
        AdsMediationManager.shared.preLoadAllAdsIfNeed()

        // Load and show splash
        if ConfigAdsManager.shared.getPlacementEnable("open_splash") {
            AdsMediationManager.shared.loadOpen("open_splash") { [weak self] _ in
                AdsMediationManager.shared.showOpenAds("open_splash", viewController: UIApplication.topViewController()!) { [weak self] _ in
                    self?.showStartVC()
                }
            }
        } else {
            AdsMediationManager.shared.loadInterAds("inter_splash") { [weak self] _ in
                AdsMediationManager.shared.showInterAds("inter_splash", viewController: UIApplication.topViewController()!) { _ in
                    self?.showStartVC()
                }
            }
        }
    }

    private func showStartVC() {
        let startVC = ViewRecord()
        UIApplication.shared.windows.first?.rootViewController = BaseNavigationController(rootViewController: startVC)
//        let firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
//        if firstLaunch {
//            if PaymentManager.shared.isPremium() == true {
//                // Vào Home
//                let startVC = ViewHome()
//                UIApplication.shared.windows.first?.rootViewController = BaseNavigationController(rootViewController: startVC)
//            } else {}
//        } else {
//            // Vào view chọn ngôn ngữ
//        }
    }
}
