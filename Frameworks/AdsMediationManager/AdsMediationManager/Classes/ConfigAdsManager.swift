//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import FirebaseRemoteConfig

open class ConfigAdsManager {
    
    public static let shared: ConfigAdsManager = ConfigAdsManager()
    
    fileprivate var remoteConfig: RemoteConfig!
    
    var counterEventMoreApp = 1
    let numberEventMoreApp = 3
    var isShowedMoreApp = false
    var localConfigs: [String: Any] = [:]
    
    fileprivate init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
    }
}

extension ConfigAdsManager{
    
    public func fetchRemoteConfig(completion: @escaping ((Bool) -> Void)){
        self.getLocalConfig()
        let expirationDuration = 0
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)){ (status, _) in
            if status == RemoteConfigFetchStatus.success{
                print("fetchRemoteConfig OK")
                self.remoteConfig.activate()
                completion(true)
            }else{
                print("fetchRemoteConfig Error")
                completion(false)
            }
        }
    }
    
    public func getConfigs() -> [String: Any]{
        let value = remoteConfig.configValue(forKey: "ios_ads_keys").dataValue
        do {
            if let json = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as? [String:Any]{
                return json
            }
        }catch let error{
            print(error)
            print("Load config from local")
            return localConfigs
        }
        print("Load config from local")
        return localConfigs
    }
    
    private func getLocalConfig(){
        if let path = Bundle.main.path(forResource: "ios_ads_keys", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: Any]{
                    print(jsonResult)
                    self.localConfigs = jsonResult
                }
              } catch {
                  print("Load json config error")
              }
        }
    }
    
    public func getAdsEnable() -> Bool{
        return getAdsConfig().0
    }
    
    public func getAdsInterval() -> Int{
        return getAdsConfig().1
    }
    
    public func getOpenInterval() -> Int{
        return getAdsConfig().2
    }
    
    private func getAdsConfig() -> (Bool, Int, Int) {
        let json = getConfigs()
        var enable = true
        var interval = 30
        var openInterVal = 10
        
        if let configs = json["configs"] as? [String: Any]{
            if let showAds = configs["enable"] as? Bool{
                enable = showAds
            }
            if let timeShow = configs["interval"] as? Int{
                interval = timeShow
            }
            if let openTimeShow = configs["open_interval"] as? Int{
                openInterVal = openTimeShow
            }
        }
        return (enable, interval, openInterVal)
    }
    
    public func setDefaultValue(_ appDefaults: [String: Any?]){
        remoteConfig.setDefaults(appDefaults as? [String: NSObject])
    }
}

//Firebase config
extension ConfigAdsManager{
    
    public func getNumber(_ key: String) -> Int{
        let value = remoteConfig.configValue(forKey: key).numberValue
        if value != 0{
            print("key \(value.intValue)")
            return value.intValue
        }
        return 0
    }
    
    public func getBool(_ key: String) -> Bool {
        let value = remoteConfig.configValue(forKey: key).boolValue
        return value
    }
    
    public func getString(_ key: String) -> String{
        let value = remoteConfig.configValue(forKey: key).stringValue
        return value ?? ""
    }
    
    public func getData(_ key: String) -> Data?{
        let value = remoteConfig.configValue(forKey: key).dataValue
        return value
    }
}

//Ads Unit
extension ConfigAdsManager{
    
    public func getAdsUnitEnable(_ key: String) -> Bool {
        for item in getAdsUnits(key){
            if item.enable == true{
                return true
            }
        }
        return false
    }
    
    public func getAdsUnits(_ key: String) -> [AdsUnit] {
        var units: [AdsUnit] = []
        let json = getConfigs()
        if let configs = json["units"] as? [String: Any]{
            if let datas = configs[key] as? [[String: Any]]{
                for item in datas{
                    let unit = AdsUnit.objInfo(item)
                    units.append(unit)
                }
            }
        }
        return units
    }
    
    public func getAllAdsUnits() -> [[AdsUnit]] {
        var units: [[AdsUnit]] = []
        let json = getConfigs()
        if let configs = json["units"] as? [String: Any]{
            for item in configs.values{
                var adsUnits: [AdsUnit] = []
                if let datas = item as? [[String: Any]]{
                    for item in datas{
                        let unit = AdsUnit.objInfo(item)
                        adsUnits.append(unit)
                    }
                }
                units.append(adsUnits)
            }
        }
        return units
    }
    
    public func getAdsUnitsJson() -> [String: Any] {
        var units: [AdsUnit] = []
        let json = getConfigs()
        if let configs = json["units"] as? [String: Any]{
            return configs
        }
        return [:]
    }
}


//Ads Placement
extension ConfigAdsManager{
    
    public func getPlacementEnable(_ key: String) -> Bool {
        if let placement = getPlacement(key){
            return placement.enable
        }
        return false
    }
    
    public func getPlacement(_ key: String) -> AdsPlacement? {
        let json = getConfigs()
        if let configs = json["placement"] as? [String: Any]{
            if let item = configs[key] as? [String: Any]{
                let placement = AdsPlacement.objInfo(item)
                return placement
            }
        }
        return nil
    }
}

open class AdsUnit{
    
    public var unitId: String = ""
    public var network: String = ""
    public var enable: Bool = true
    public var allowPreLoad: Bool = false
    public var ads_type: String = ""

    class func objInfo(_ info: [String: Any]) -> AdsUnit{
        let adsUnit = AdsUnit()
        
        if let unitId = info["unit_id"] as? String{
            adsUnit.unitId = unitId
        }
        
        if let network = info["network"] as? String{
            adsUnit.network = network
        }
        
        if let enable = info["enable"] as? Bool{
            adsUnit.enable = enable
        }
        
        if let allowPreLoad = info["allowPreLoad"] as? Bool{
            adsUnit.allowPreLoad = allowPreLoad
        }
        
        if let ads_type = info["ads_type"] as? String{
            adsUnit.ads_type = ads_type
        }
                
        return adsUnit
    }
    
    public func printInfo(){
        print("_________________________________________________________________")

        print("UnitId: \(unitId)")
        print("network: \(network)")
        print("enable: \(enable)")
    }
}

open class AdsPlacement{

    public var ads_unit: String = ""
    public var network: String = ""
    public var enable: Bool = true
    public var position: String = ""
    public var collapsible: Bool = false
    public var direct: Bool = true
    
    class func objInfo(_ info: [String: Any]) -> AdsPlacement{
        
        let adsPlacement = AdsPlacement()
        
        if let unitId = info["ads_unit"] as? String{
            adsPlacement.ads_unit = unitId
        }
        
        if let network = info["network"] as? String{
            adsPlacement.network = network
        }
        
        if let enable = info["enable"] as? Bool{
            adsPlacement.enable = enable
        }
        
        if let position = info["position"] as? String{
            adsPlacement.position = position
        }
        
        if let collapsible = info["collapsible"] as? Bool{
            adsPlacement.collapsible = collapsible
        }
        
        if let direct = info["show_direct"] as? Bool{
            adsPlacement.direct = direct
        }
        return adsPlacement
    }
    
    public func printInfo(){
        print("_________________________________________________________________")

        print("UnitId: \(ads_unit)")
        print("network: \(network)")
        print("enable: \(enable)")
        print("position: \(position)")
        print("collapsibel: \(collapsible)")
        print("direct: \(direct)")
    }
}
