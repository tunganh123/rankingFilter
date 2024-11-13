//
//  DeviceType.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

public let screenSize = UIScreen.main.bounds.size

let iPhone = (UIDevice.current.userInterfaceIdiom == .phone)
let iPad = (UIDevice.current.userInterfaceIdiom == .pad)

public var hasTopNotch: Bool { /// with notch: 44.0 on iPhone X, XS, XS Max, XR. and above
    if #available(iOS 13.0,  *) {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
    } else {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}

enum Device {
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6p
    case iPhoneX
    case iPhoneXS
    case iPhoneXR
    case iPhoneXSMax
    case iPad
    case iPadPro105
    case iPadPro129

    var size: CGSize {
        switch self {
        case .iPhone4: return CGSize(width: 320, height: 480)
        case .iPhone5: return CGSize(width: 320, height: 568)
        case .iPhone6: return CGSize(width: 375, height: 667)
        case .iPhone6p: return CGSize(width: 414, height: 736)
        case .iPhoneX: return CGSize(width: 375, height: 812)
        case .iPhoneXS: return CGSize(width: 375, height: 812)
        case .iPhoneXR: return CGSize(width: 414, height: 896)
        case .iPhoneXSMax: return CGSize(width: 414, height: 896)
        case .iPad: return CGSize(width: 768, height: 1024)
        case .iPadPro105: return CGSize(width: 834, height: 1112)
        case .iPadPro129: return CGSize(width: 1024, height: 1366)
        }
    }
}

struct DeviceType {
    static let IS_IPHONE        = iPhone
    static let IS_IPHONE_4      = (iPhone && Device.iPhone4.size == screenSize)
    static let IS_IPHONE_5      = (iPhone && Device.iPhone5.size == screenSize)
    static let IS_IPHONE_6      = (iPhone && Device.iPhone6.size == screenSize)
    static let IS_IPHONE_6P     = (iPhone && Device.iPhone6p.size == screenSize)
    static let IS_IPHONE_7      = IS_IPHONE_6
    static let IS_IPHONE_7P     = IS_IPHONE_6P
    static let IS_IPHONE_X      = (iPhone && Device.iPhoneX.size == screenSize)
    static let IS_IPHONE_XS     = (iPhone && Device.iPhoneXS.size == screenSize)
    static let IS_IPHONE_XR     = (iPhone && Device.iPhoneXR.size == screenSize)
    static let IS_IPHONE_XSMAX  = (iPhone && Device.iPhoneXSMax.size == screenSize)
    static let IS_IPAD          = iPad
    static let IS_IPAD_PRO_10_5 = iPad && Device.iPadPro105.size == screenSize
    static let IS_IPAD_PRO_12_9 = iPad && Device.iPadPro129.size == screenSize
    static let IS_TV            = UIDevice.current.userInterfaceIdiom == .tv
    static let IS_CAR_PLAY      = UIDevice.current.userInterfaceIdiom == .carPlay
}

struct Version {
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let iOS10 = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
}
