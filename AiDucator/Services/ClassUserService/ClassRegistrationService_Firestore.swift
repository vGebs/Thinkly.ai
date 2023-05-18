//
//  ClassUserService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import Combine
import FirebaseFirestore

class ClassRegistrationService_Firestore {
    
    private let firestore = FirestoreWrapper.shared
    
    private let collection = "ClassRegistration"
    private let db = Firestore.firestore()
    
    static let shared = ClassRegistrationService_Firestore()
    
    private init() {  }
    
    func joinClass(classUser: ClassRegristration) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: classUser)
    }
    
    func getRegristrations(for uid: String) -> AnyPublisher<[ClassRegristration], Error> {
        let query: Query = db.collection(collection).whereField("userID", isEqualTo: uid)
        return firestore.read(query: query)
    }
    
    func dropClass(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
    
    func listenOnRegristrations(for uid: String) -> AnyPublisher<[(ClassRegristration, DocumentChangeType)], Error> {
        let query: Query = db.collection(collection).whereField("userID", isEqualTo: uid)
        return firestore.listenByQuery(query: query)
    }
}
