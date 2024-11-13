//
//  Model.swift
//  Ar-draw
//
//  Created by TungAnh on 15/6/24.
//

import Foundation
import SwiftyJSON

// Mô hình cho dữ liệu desk
struct Desk: Codable {
    let info: String
    let url: String
    let folder: String
    let likeCount: Int
    let downloads: Int
    let isFree: Bool
    let id: String
    let name: String
    let v: Int

    // Init method using SwiftyJSON
    init(_ json: JSON) {
        info = json["info"].stringValue
        url = json["url"].stringValue
        folder = json["folder"].stringValue
        likeCount = json["like_count"].intValue
        downloads = json["downloads"].intValue
        isFree = json["isFree"].boolValue
        id = json["_id"].stringValue
        name = json["name"].stringValue
        v = json["__v"].intValue
    }

    func getNameImg() -> String {
        return "https://wallpaperhd.nyc3.cdn.digitaloceanspaces.com/HeadsUp/\(folder)/thumb.png"
    }
}

struct CategoryItem: Codable {
    let name: String
    let folder: String
    let from: Int
    let to: Int
    // Hàm khởi tạo mặc định
    init(_ json: JSON) {
        name = json["name"].stringValue
        folder = json["folder"].stringValue
        from = json["from"].intValue
        to = json["to"].intValue
    }

    func getUrlimage(ind: IndexPath) -> String {
        var indok: String!
        if ind.row < 10 {
            indok = "0\(ind.row + 1)"
        } else {
            indok = String(ind.row + 1)
        }
        let stringurl = "https://wallpaperhd.nyc3.cdn.digitaloceanspaces.com/ARDraw/\(folder)/\(indok!).png"

        let encodedString = stringurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        return encodedString
    }

    func getURL_thumb(ind: IndexPath) -> String {
        var indok: String!
        if ind.row + 1 < 10 {
            indok = "0\(ind.row + 1)"
        } else {
            indok = String(ind.row + 1)
        }
        let stringurl = "https://wallpaperhd.nyc3.cdn.digitaloceanspaces.com/ARDraw/\(folder)/thumb/\(indok!).png"

        let encodedString = stringurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        return encodedString
    }

    func getURL_ori(ind: IndexPath) -> String {
        var indok: String!
        if ind.row + 1 < 10 {
            indok = "0\(ind.row + 1)"
        } else {
            indok = String(ind.row + 1)
        }
        let stringurl = "https://wallpaperhd.nyc3.cdn.digitaloceanspaces.com/ARDraw/\(folder)/ori/\(indok!).png"

        let encodedString = stringurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        return encodedString
    }
}

// if let encodedString = stringurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//   let url = URL(string: encodedString)
