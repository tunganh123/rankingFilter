//
//  BaseAPI.swift
//  Stickify2024
//
//  Created by DucVV on 25/05/2024.
//
 
import Alamofire
import Foundation
import Moya
 
enum RootAPI {
    static let url_homepage = "http://147.182.196.25/desk/homepage"
    static let url_getCategory = "https://wallpaperhd.nyc3.cdn.digitaloceanspaces.com/ARDraw/categories.json"
    static let url_detail = "http://147.182.196.25/desk/detail"
}

enum ServiceManager {
    case BASE_HOME
    case BASE_CATEGORY
}

extension ServiceManager: TargetType {
    var baseURL: URL {
        switch self {
        case .BASE_HOME:
            return URL(string: RootAPI.url_homepage)!
        case .BASE_CATEGORY:
            return URL(string: RootAPI.url_getCategory)!
        }
    }

    var ServiceAppId: String {
        return "1"
    }
    
    var path: String {
        switch self {
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .BASE_CATEGORY:
             return .get
             default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Moya.Task {
        switch self {
        case .BASE_HOME:
            let parameters: [String: Any] = [
                "appId": ServiceAppId
            ]
            return .requestCompositeParameters(bodyParameters: parameters, bodyEncoding: JSONEncoding.default, urlParameters: [:])
       
        default:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        default:
            let currentTime = Int(Date().timeIntervalSince1970 * 1000)
            let token = "\(currentTime)\("amdhw13W9mCnvjm2n5cnAI12vn@dsljfh322@dkdk")".MD5()
            let header = ["unittime": "\(currentTime)", "token": token]
            return header
        }
    }
}
