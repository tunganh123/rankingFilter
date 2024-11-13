//
//  Constant.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

public let appName             = "iStandBy: Top Widgets Themes"
public let appid               = "6467385403"
public let linkApp             = "https://apps.apple.com/app/id" + appid
public let mailSupport         = "cemsoftware.hoangtien@gmail.com"
public let ID_APP_GROUP        = "group.com.cem.standby.widgets"
public let NumberWidgetPerPage = 10
public let DeviceID            = UIDevice.current.identifierForVendor?.uuidString ?? ""

public let isIPad = DeviceType.IS_IPAD
public let heightRatio = screenSize.height/812
public let widthRatio = screenSize.width/375

public var ratioScreen: CGFloat {
    var sizeScale: CGFloat = 1
    if DeviceType.IS_IPAD {
        sizeScale = 1.25
    } else if DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_7 {
        sizeScale = 0.95
    } else if DeviceType.IS_IPHONE_5 {
        sizeScale = 0.9
    }
    return sizeScale
}
