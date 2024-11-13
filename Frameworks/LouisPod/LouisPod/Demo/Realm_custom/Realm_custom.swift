//
//  Realm_custom.swift
//  HeadUptest
//
//  Created by Tung Anh on 11/05/2024.
// 

import Foundation
import RealmSwift

class Realm_custom: Object {
    @objc dynamic var url_img: String?
    @objc dynamic var des_desk: String?
    @objc dynamic var title_desk: String?
     var arr_keyword = List<Keyword>()
}

class Keyword: Object {
    @objc dynamic var value: String?
}
