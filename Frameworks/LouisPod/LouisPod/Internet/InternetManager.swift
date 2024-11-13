//
//  InternetManager.swift
//  AdsMediationManager
//
//  Created by Duc Vu Van on 23/10/2023.
//

import Foundation
import Network
import UIKit
import SystemConfiguration
public class InternetManager{
    public static let shared = InternetManager()
    public var isInternet = false
    public func check(completing: @escaping ((Bool) -> Void) ){
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    
                    completing(self.isConnectedToNetwork())
                }
            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    completing(self.isConnectedToNetwork())
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        self.isInternet = ret
        return ret
    }
}
