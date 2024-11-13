//
//  Language_manager.swift
//  LouisPod
//
//  Created by TungAnh on 24/5/24.
//

import Foundation

public protocol LanguageChangeDelegate: AnyObject {
    func languageDidChange()
}

public enum LanguageManager {
    public static var currentLanguage: String = "en"
    weak static var delegate: LanguageChangeDelegate?
    public static func changeLanguage(to language: String) {
        currentLanguage = language
        delegate?.languageDidChange()
    }
}
