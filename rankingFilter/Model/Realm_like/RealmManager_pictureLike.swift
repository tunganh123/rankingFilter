//
//  RealmManager_pictureLike.swift
//  Ar-draw
//
//  Created by TungAnh on 17/6/24.
//
import Combine
import Foundation
import RealmSwift

class RealmManager_pictureLike {
    static let shared = RealmManager_pictureLike()
    let realm: Realm
    @Published var ArrPictureLike: Results<like_item>
    private init() {
        let config = Realm.Configuration(
            schemaVersion: 2, // tang version len thi doi model
            migrationBlock: { _, _ in

            })

        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
        ArrPictureLike = realm.objects(like_item.self)
    }

    func getData_Like() -> AnyPublisher<Results<like_item>, Error> {
        return Future<Results<like_item>, Error> { [weak self] promise in
            guard let realm = self?.realm else {
                let error = NSError(domain: "YourClass", code: 0, userInfo: [NSLocalizedDescriptionKey: "Realm is nil"])
                promise(.failure(error))
                return
            }

            let results = realm.objects(like_item.self)
            promise(.success(results))
        }
        .eraseToAnyPublisher()
    }

    func addData_Like(_ object: like_item) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [self] promise in
            do {
                try realm.write {
                    realm.add(object)
                }
                // Cập nhật danh sách CurrencyItems khi có sự thay đổi
                ArrPictureLike = realm.objects(like_item.self)
                promise(.success(()))
            } catch {
                promise(.failure(error))
                print("Error adding object to Realm: \(error)")
            }
        }.eraseToAnyPublisher()
    }

    func editData_Like(_ object: like_item, with newData: like_item) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [self] promise in
            do {
                try realm.write {
                    // Cập nhật dữ liệu của đối tượng hiện tại với dữ liệu mới
                    object.url_thumb = newData.url_thumb
                    object.url_origin = newData.url_origin
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
                print("Error editing object in Realm: \(error)")
            }
        }.eraseToAnyPublisher()
    }

    // Xoá toàn bộ các CurrencyItem
    func deleteAllData_Like() {
        do {
            try realm.write {
                realm.delete(realm.objects(like_item.self))
                // Cập nhật danh sách CurrencyItems khi có sự thay đổi
                ArrPictureLike = realm.objects(like_item.self)
            }
        } catch {
            print("Error deleting all objects from Realm: \(error)")
        }
    }

    // Xoá đối tượng khỏi Realm
    func deleteData_Like(_ object: like_item) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                if let item = self.ArrPictureLike.first(where: {
                    $0.url_thumb == object.url_thumb
                }) {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                    promise(.success(()))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
