//
//  Utilities.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit

import CoreLocation

// import SDWebImage
import Toast_Swift

public func printToConsole(_ message: Any) {
    #if DEBUG
        print(message)
    #endif
}

public func openUrl(urlString: String) {
    if let url = URL(string: urlString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

public func showAlertOpenSetting(title: String?, message: String?, completionCancel: (() -> Void)?) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    let openSettingAction = UIAlertAction(title: AlertActionType.openSetting.title, style: .default) { _ in
        openSetting()
    }
    let cancelAction = UIAlertAction(title: AlertActionType.cancel.title, style: .cancel, handler: { _ in
        completionCancel?()
    })
    alert.addAction(openSettingAction)
    alert.addAction(cancelAction)
    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
}

public func openSetting(completion: (() -> Void) = {}) {
    if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(settingUrl) {
            UIApplication.shared.open(settingUrl)
            completion()
        }
    }
}

public func after(interval: TimeInterval, completion: (() -> Void)?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
        completion?()
    }
}

public func asyncDispatch(completion: (() -> Void)?) {
    DispatchQueue.main.async {
        completion?()
    }
}

public func actionShare(viewController: UIViewController, items: [Any], completion: (() -> Void)? = nil) {
    let activityViewController = UIActivityViewController(activityItems: items,
                                                          applicationActivities: nil)
    activityViewController.completionWithItemsHandler = { _, _, _, _ in
        completion?()
    }
    if isIPad,
       let popoverController = activityViewController.popoverPresentationController
    {
        popoverController.sourceView = viewController.view
        popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                              y: viewController.view.bounds.midY,
                                              width: 0,
                                              height: 0)
        popoverController.permittedArrowDirections = []
    }
    viewController.present(activityViewController, animated: true, completion: nil)
}

// MARK: - Enums

public enum AlertActionType {
    case cancel
    case ok
    case openSetting
    case close
    case delete

    var title: String {
        switch self {
        case .cancel:
            return "Cancel"
        case .ok:
            return "Ok"
        case .openSetting:
            return "Open Setting"
        case .close:
            return "Close"
        case .delete:
            return "Delete"
        }
    }
}

// private var timer: Timer?
// public func debounce(delay: TimeInterval, completion: (() -> Void)?) {
//    timer?.invalidate()
//    timer = Timer.scheduledTimer(withTimeInterval: delay,
//                                 repeats: false,
//                                 block: { _ in
//        completion?()
//    })
// }
