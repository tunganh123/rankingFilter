//
//  UserDefault_manager.swift
//  LouisPod
//
//  Created by TungAnh on 24/5/24.
//

import Foundation

public class UserDefault_manager: NSObject {
    public static let shared = UserDefault_manager()

    public func getData(key: String) -> Any {
        return UserDefaults.standard.value(forKey: key) as Any
    }

    public func setData(value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
