//
//  Subject_manager.swift
//  LouisPod
//
//  Created by TungAnh on 24/5/24.
//

import Combine
import Foundation

@available(iOS 13.0, *)
public class Subject_manager {
    public static let shared = Subject_manager()
    private init() {}

    // Publisher để phát dữ liệu
    public var dataPublisher = PassthroughSubject<Bool, Never>() 
    public var SuggestPublisher = PassthroughSubject<Bool, Never>()
}
