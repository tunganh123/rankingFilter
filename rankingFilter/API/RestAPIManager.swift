//
//  RestAPIManager.swift
//  Stickify2024
//
//  Created by DucVV on 27/05/2024.
//

import Moya
import SwiftyJSON

public class RestApiManager {
    static var shared = RestApiManager()
    static var dataFree: [Desk] = []
    let provider = MoyaProvider<ServiceManager>()
    func getDatahome(completion: @escaping (_ freeDesk: [Desk], _ paidDesk: [Desk]) -> Void) {
        provider.request(.BASE_HOME) { result in
            switch result {
            case .success(let response):
                do {
                    let json = try JSON(data: response.data)
                    var freeDesk = [Desk]()
                    var paidDesk = [Desk]()

                    RestApiManager.dataFree = freeDesk

                    let dataFree = json["data"]["freeDesk"].arrayValue
                    freeDesk = dataFree.map { Desk($0) }

                    let dataPaid = json["data"]["paidDesk"].arrayValue
                    paidDesk = dataPaid.map { Desk($0) }
                    // Call completion handler with parsed data
                    completion(freeDesk, paidDesk)
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }

            case .failure(let err):
                print("errr", err.localizedDescription)
            }
        }
    }

    func getDataCategory(completion: @escaping (_ Cate: [CategoryItem]) -> Void) {
        provider.request(.BASE_CATEGORY) { result in
            switch result {
            case .success(let response):
                do {
                    let json = try JSON(data: response.data)
                    let data = json["data"].arrayValue
                    let dataCate = data.map { CategoryItem($0) }

                    completion(dataCate)

                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }

            case .failure(let err):
                print("errr", err.localizedDescription)
            }
        }
    }
//    func getLikeDownNew(completion: @escaping ((_ arrayBanner : [ItemSticker],_ arrayDown : [ItemSticker],_ arrayLike : [ItemSticker],_ arrayNew : [ItemSticker],_ arrayCategories: [Categories] ) -> Void)){
//        provider.request(.BASE_HOME) { result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                let dataBanner = json["data"]["banner"].arrayValue
//                let arrayBanner = dataBanner.map({ItemSticker($0)})
//
//                let dataDownload = json["data"]["download"].arrayValue
//                let arrayDown = dataDownload.map({ItemSticker($0)})
//
//                let dataLike = json["data"]["like"].arrayValue
//                let arrayLike = dataLike.map({ItemSticker($0)})
//
//                let dataNew = json["data"]["newlest"].arrayValue
//                let arrayNew = dataNew.map({ItemSticker($0)})
//
//                let dataCate = json["data"]["categories"].arrayValue
//                let arrayCate = dataCate.map({Categories($0)})
//
//                completion(arrayBanner,arrayDown,arrayLike,arrayNew,arrayCate)
//            case .failure:
//                completion([], [], [], [], [])
//            }
//        }
//    }

//    func getList(page: Int, sort: Int,completion: @escaping ((_ arrayList: [ItemSticker]) -> Void)){
//        provider.request(.BASE_LIST(page: page, sort: sort)) { result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                let data = json["data"].arrayValue
//                let arrayData = data.map({ItemSticker($0)})
//                completion(arrayData)
//            case .failure:
//                completion([])
//            }
//        }
//    }
//
//    func getCategories(page: Int, category: String,completion: @escaping (([ItemSticker]) -> Void)){
//        provider.request(.BASE_CATEGORIES(page: page, category: category)) { result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                let data = json["data"].arrayValue
//                let arrayData = data.map({ItemSticker($0)})
//                completion(arrayData)
//            case .failure:
//                completion([])
//            }
//        }
//    }
//
//    func getDetailPack(folder: String,completion: @escaping (([Stickers], Bool) -> Void)){
//        provider.request(.BASE_IMAGE(folder: folder)) { result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                print(response)
//                let data = json["sticker_packs"][0]["stickers"].arrayValue
//                let arraydata = data.map({Stickers($0)})
//                let animated = json["sticker_packs"][0]["animated_sticker_pack"].boolValue
//                completion(arraydata, animated)
//            case .failure:
//                completion([], false)
//            }
//        }
//    }
//
//    func getLike(id: String, idDevice: String,completion: @escaping (() -> Void)){
//        provider.request(.BASE_LIKE(id: id, idDevice: idDevice)) { result in
//            completion()
//        }
//    }
//
//    func getListDownload(page: Int,completion: @escaping (([ItemSticker]) -> Void)){
//        provider.request(.BASE_LIST_DOWNLOAD(page: page)){ result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                let data = json["data"].arrayValue
//                let arrayData = data.map({ItemSticker($0)})
//                completion(arrayData)
//            case .failure:
//                completion([])
//            }
//        }
//    }
//
//    func getListLike(page: Int,completion: @escaping (([ItemSticker]) -> Void)){
//        provider.request(.BASE_LIST_LIKE(page: page)){ result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                let data = json["data"].arrayValue
//                let arrayData = data.map({ItemSticker($0)})
//                completion(arrayData)
//            case .failure:
//                completion([])
//            }
//        }
//    }
//
//    func getBaseDownload(id: String, idDevice: String,completion: @escaping (() -> Void)){
//        provider.request(.BASE_SEND_DOWNLOAD(id: id, idDevice: idDevice)) { result in
//            print(result)
//            completion()
//        }
//    }
}
