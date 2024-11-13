//
//  ViewCustomVM.swift
//  HeadUptest
//
//  Created by TungAnh on 11/5/24.
//

import Alamofire
import Combine
import Foundation

struct CustomDeckData: Codable {
    let status: String
    let data: [CustomDeckFolder]
}

struct CustomDeckFolder: Codable {
    let url: String
    let folder: String
    let title: String
    let from: Int
    let to: Int
}

class ViewCustomVM {
    static let shared = ViewCustomVM()
    private var cancellables: Set<AnyCancellable> = []

    func fetch_custom_deck() -> AnyPublisher<CustomDeckData, Error> {
        return Future<CustomDeckData, Error> { promise in
            AF.request("url").validate().responseDecodable(of: CustomDeckData.self) { response in
                switch response.result {
                case .success(let datas):
                    promise(.success(datas))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func add_customdesk(customdesk: Realm_custom, cls: @escaping () -> Void) {
        Realm_manager_customdesk.shared.addcustomlist(customdesk).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error add object: \(error)")
            case .finished:
                cls()
                print("Object add successfully")
            }
        }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func Edit_customdesk(item_Edit: Realm_custom, item_new: Realm_custom, cls: @escaping () -> Void) {
        Realm_manager_customdesk.shared.editcustomlist(item_Edit, with: item_new).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error edit object: \(error)")
            case .finished:
                cls()
                print("Object edit successfully")
            }
        }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
