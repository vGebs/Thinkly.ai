//
//  UserService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import Combine
import FirebaseFirestore

class UserService_Firestore {
    private let firestore = FirestoreWrapper.shared
    
    static let shared = UserService_Firestore()
    
    private let db = Firestore.firestore()
    
    let collection = "Users"
    
    private init() {}
    
    func createUser(_ user: UserFirestore) -> AnyPublisher<String, Error> {
        firestore.create(collection: collection, data: user)
    }
    
    func fetchUser(with uid: String) -> AnyPublisher<UserFirestore?, Error> {
        let query: Query = db.collection(collection).whereField("uid", isEqualTo: uid)
        return firestore.read(query: query)
            .map { users -> UserFirestore? in
                return users.first
            }
            .eraseToAnyPublisher()
    }
    
    func updateName(_ user: UserFirestore, docID: String) -> AnyPublisher<Void, Error> {
        firestore.update(collection: collection, documentId: docID, data: user)
    }
    
    func deleteUser(docID: String) -> AnyPublisher<Void, Error> {
        firestore.delete(collection: collection, documentId: docID)
    }
}
