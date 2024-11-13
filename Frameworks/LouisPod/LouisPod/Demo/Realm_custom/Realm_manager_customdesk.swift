//
//  Realm_manager_customdesk.swift
//  HeadUptest
//
//  Created by Tung Anh on 11/05/2024.
//

import Combine
import Foundation
import RealmSwift

class Realm_manager_customdesk {
    static let shared = Realm_manager_customdesk()
    let realm: Realm
    @Published var Realm_customlist: Results<Realm_custom>
    private init() {
        // Khởi tạo Realm trong constructor private để ngăn chặn việc tạo thêm đối tượng RealmManager
        realm = try! Realm()
        Realm_customlist = realm.objects(Realm_custom.self)
    }

    func getcustomlist() -> AnyPublisher<Results<Realm_custom>, Error> {
        return Future<Results<Realm_custom>, Error> { [weak self] promise in
            guard let realm = self?.realm else {
                let error = NSError(domain: "YourClass", code: 0, userInfo: [NSLocalizedDescriptionKey: "Realm is nil"])
                promise(.failure(error))
                return
            }

            let results = realm.objects(Realm_custom.self)
            promise(.success(results))
        }
        .eraseToAnyPublisher()
    }

    func editcustomlist(_ object: Realm_custom, with newData: Realm_custom) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [self] promise in
            do {
                try realm.write {
                    // Cập nhật dữ liệu của đối tượng hiện tại với dữ liệu mới
                    object.des_desk = newData.des_desk
                    object.title_desk = newData.title_desk
                    object.url_img = newData.url_img
                    // Xóa tất cả các phần tử cũ trong arr_keyword
                    object.arr_keyword.removeAll()

                    // Thêm các phần tử mới vào arr_keyword
                    for keyword in newData.arr_keyword {
                        let newKeyword = Keyword()
                        newKeyword.value = keyword.value
                        object.arr_keyword.append(newKeyword)
                    }
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
                print("Error editing object in Realm: \(error)")
            }
        }.eraseToAnyPublisher()
    }

    func addcustomlist(_ object: Realm_custom) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [self] promise in
            do {
                try realm.write {
                    realm.add(object)
                }
                // Cập nhật danh sách CurrencyItems khi có sự thay đổi
                Realm_customlist = realm.objects(Realm_custom.self)
                promise(.success(()))
            } catch {
                promise(.failure(error))
                print("Error adding object to Realm: \(error)")
            }
        }.eraseToAnyPublisher()
    }

    // Xoá toàn bộ các CurrencyItem
    func deleteAllcustomlist() {
        do {
            try realm.write {
                realm.delete(realm.objects(Realm_custom.self))
                // Cập nhật danh sách CurrencyItems khi có sự thay đổi
                Realm_customlist = realm.objects(Realm_custom.self)
            }
        } catch {
            print("Error deleting all objects from Realm: \(error)")
        }
    }

    // Xoá đối tượng khỏi Realm
    func delete_custom(_ object: Realm_custom) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.realm.write {
                    self.realm.delete(object)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
