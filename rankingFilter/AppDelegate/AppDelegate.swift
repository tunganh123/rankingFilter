//
//  AppDelegate.swift
//  DrawLockScreen
//
//  Created by TungAnh on 27/6/24.
//
import AdsMediationManager
import AppsFlyerAdRevenue
import AppsFlyerLib
import AppTrackingTransparency
import AVFoundation
import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import IQKeyboardManagerSwift
import LouisPod
import Qonversion
import SwiftyStoreKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var isFromBackground = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        requestCameraAndMicrophoneAccess()

        configureAnalytic()
        configurePayment()
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        setRoot()
        setup_userDefault()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        isFromBackground = true
    }

    // Appsflyer và open ads
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().start()

        if isFromBackground {
            isFromBackground = false
            AdsMediationManager.shared.showOpenAds("open_ads", viewController: UIApplication.currentTopVC()!, handleAdDidDismiss: nil)
        }
    }

    func setup_userDefault() {
        let countFinger = UserDefault_manager.shared.getData(key: "countFinger") as? Int
        if countFinger == nil {
            // Tracking
            EventManager.logEvent("open_first", params: ["TIME": Date()])

            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "dateFirstApp")
        }
    }

    func setRoot() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BaseNavigationController(rootViewController: onboardVC())
        window?.makeKeyAndVisible()
    }
}

// MARK: - - Ads

extension AppDelegate {
    func configureAnalytic() {
        FirebaseApp.configure()

        let config = Qonversion.Configuration(projectKey: "hemMKr-5B1xYRKFNnCTjwWRTZyVFRxat", launchMode: .analytics)
        Qonversion.initWithConfig(config)

        if let appInstanceID = Analytics.appInstanceID() {
            Qonversion.shared().setUserProperty(.firebaseAppInstanceId, value: appInstanceID)
        }
        Qonversion.shared().collectAppleSearchAdsAttribution()

        setUpAppsflyer()
    }

    private func setUpAppsflyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "k7fyBqQm2ys9iZowhKjhBn"
        AppsFlyerLib.shared().appleAppID = ID_APP
        AppsFlyerLib.shared().delegate = self
        AppsFlyerAdRevenue.start()
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("onConversionDataSuccess")
        Qonversion.shared().setUserProperty(.appsFlyerUserID, value: AppsFlyerLib.shared().getAppsFlyerUID())
    }

    func onConversionDataFail(_ error: Error) {
        print(error)
    }
}

// MARK: - - In-App Purchase

extension AppDelegate {
    func configurePayment() {
        PaymentManager.shared.initPayment(productIds: KEY_INAPP_IDS, secretKey: KEY_INAPP_SECRET)
    }
}

extension AppDelegate {
    func requestCameraAndMicrophoneAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera access granted.")
            } else {
                print("Camera access denied.")
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Microphone access granted.")
            } else {
                print("Microphone access denied.")
            }
        }
    }
}
