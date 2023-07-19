//
//  UnitService_firestore.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-13.
//

import Foundation
import Combine
import FirebaseFirestore

class UnitService_firestore {
    
    static let shared = UnitService_firestore()
    
    private init() {}
    
    private let db = Firestore.firestore()
    
    private let collection = "Units"
    
    func pushUnits(units: [Unit], courseID: String) -> AnyPublisher<String, Error> {
        let units = Units_firestore(units: units, courseID: courseID)
        return FirestoreWrapper.shared.create(collection: self.collection, data: units)
    }
    
    func fetchUnits(courseID: String) -> AnyPublisher<[Curriculum], Error> {
        let query = db.collection(collection).whereField("courseID", isEqualTo: courseID)
        return FirestoreWrapper.shared.read(query: query)
    }
}

import FirebaseFirestoreSwift

struct Units_firestore: Codable, FirestoreProtocol {
    @DocumentID var documentID: String?
    var units: [Unit]
    var courseID: String
}
