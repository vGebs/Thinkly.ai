//
//  ClassUserService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import Combine

class ClassUserService_Firestore {
    
    private let firestore = FirestoreWrapper.shared
    
    private let collection = "ClassUser"
    
    static let shared = ClassUserService_Firestore()
    
    private init() {  }
    
    func joinClass(classUser: ClassUser) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: classUser)
    }
    
    func dropClass(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}
