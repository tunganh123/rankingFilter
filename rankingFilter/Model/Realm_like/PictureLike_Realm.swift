//
//  PictureLike_Realm.swift
//  Ar-draw
//
//  Created by TungAnh on 17/6/24.
//

import Foundation
import RealmSwift

class like_item: Object {
    @objc dynamic var url_thumb: String?
    @objc dynamic var url_origin: String?
    @objc dynamic var countlike: Int = 0
}
