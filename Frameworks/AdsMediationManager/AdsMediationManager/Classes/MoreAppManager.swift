//
//  MoreAppManager.swift
//  AdsMediationManager
//
//  Created by Admin on 09/11/2023.
//

import Foundation

open class MoreAppManager {
    
    public static let shared: MoreAppManager = MoreAppManager()
    
    var counterEventMoreApp = 0
    let numberEventMoreApp = 2
    var isShowedMoreApp = false

    public func logEventToShowMoreApp(){
        counterEventMoreApp = counterEventMoreApp + 1
        if counterEventMoreApp % numberEventMoreApp == 0{
            if self.getLoopMoreApp() == 1{
                checkAndShowMoreApp()
            }else{
                if !isShowedMoreApp{
                    isShowedMoreApp = true
                    checkAndShowMoreApp()
                }
            }
        }
    }
    
    public func checkAndShowMoreApp(){
        if let value = ConfigAdsManager.shared.getData("MoreApp2"){
            do {
                if let json = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as? [String:Any]{
                    guard let version = json["version"] as? String else {return }
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                    if version.contains(appVersion) || version == "All"{

                        if let data = json["data"] as? [[String:String]]{
                            for item in data{
                                guard let title = item["title"] else {return }
                                guard let message = item["message"] else {return }
                                guard let link = item["link"] else {return }
                                let str = item["button"] ?? "OK"
                                
                                //If installed can not show this app
                                if let open = item["open"], let openUrl = URL(string: open){
                                    if UIApplication.shared.canOpenURL(openUrl){
                                        self.saveMoreApp(link)
                                    }
                                }
                                
                                if !self.checkIsShowedMoreApp(link){
                                    self.saveMoreApp(link)
                                    EventManager.logEvent("ShowMoreApp", params: ["link":link])
                                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: str, style: .default, handler: { action in
                                        EventManager.logEvent("ClickMoreApp", params: ["link":link])
                                        if let url = URL(string: link){
                                            if UIApplication.shared.canOpenURL(url){
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                    }))
                                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                    MoreAppManager.shared.topViewController()?.present(alert, animated: true)
                                    break
                                }
                            }
                        }
                    }
                }
            }catch let error{
                print(error)
            }
        }
    }
        
    func checkIsShowedMoreApp(_ link: String) -> Bool{
        if let links = UserDefaults.standard.value(forKey: "ShowedMoreApp") as? [String]{
            return links.contains(link)
        }
        return false
    }
    
    func saveMoreApp(_ link: String){
        if let links = UserDefaults.standard.value(forKey: "ShowedMoreApp") as? [String]{
            var data: [String] = []
            data.append(contentsOf: links)
            data.append(link)
            UserDefaults.standard.setValue(data, forKey: "ShowedMoreApp")
        }else{
            UserDefaults.standard.setValue([link], forKey: "ShowedMoreApp")
        }
    }
    
    func removeAllShowedMoreApp(){
        UserDefaults.standard.setValue([], forKey: "ShowedMoreApp")
    }
    
    public func getLoopMoreApp() -> Int {
        let value = ConfigAdsManager.shared.getNumber("LoopMoreApp")
        if value != 0 {
            print("getLoopMoreApp \(value)")
            return value
        }
        return 0
    }
    
    public func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
