//
//  Data_firebase.swift
//  Ar-draw
//
//  Created by TungAnh on 26/6/24.
//
import FirebaseDatabase

import Foundation

class FirebaseService {
    private let databaseRef = Database.database().reference()

    func createFireBaseRating(dataRating: Data_firebase_Rating, completion: @escaping (Error?) -> Void) {
        let datenow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: datenow)

        let deskRef = databaseRef.child(formattedDate).child(dataRating.id)
        deskRef.setValue(dataRating.toDictionary()) { error, _ in
            completion(error)
        }
    }
}

struct Data_firebase_Rating {
    let id: String
    let Rating: Int
    let Des: String

    init(id: String, Rating: Int, Des: String) {
        self.id = id
        self.Rating = Rating
        self.Des = Des
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "Rating": Rating,
            "Description": Des
        ]
    }
}
