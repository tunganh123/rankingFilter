//
//  FileManager+.swift
//  BaseProjectFramework
//
//  Created by Thiện Tùng on 28/09/2023.
//

import Foundation

extension FileManager {
    public func appGroupDocumentDir() -> URL {
        return (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ID_APP_GROUP)?.appendingPathComponent("db.realm"))!
    }
    
    public func getDocumentAppDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("StandbyWidget")
    }
    
    public func sharedAppGroupURL() -> URL {
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: ID_APP_GROUP)!
    }
}
func infoForKey(_ key: String) -> String? {
    return (Bundle.main.infoDictionary?[key] as? String)?
        .replacingOccurrences(of: "\\", with: "")
}
