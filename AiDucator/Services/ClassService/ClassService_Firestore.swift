//
//  File.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine
import FirebaseFirestore

class ClassService_Firestore {
    
    static let shared = ClassService_Firestore()
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "Classes"
    
    private let db = Firestore.firestore()
    
    private init() {  }
    
    func addClass(_ cls: Class) -> AnyPublisher<Void, Error> {
        return firestore.create(collection: collection, data: cls)
    }
    
    func getClass(with docID: String) -> AnyPublisher<Class, Error> {
        return firestore.read(collection: collection, documentId: docID)
    }
    
    func getClasses(for teacherID: String) -> AnyPublisher<[Class], Error> {
        
        let query: Query = db.collection(collection).whereField("teacherID", isEqualTo: teacherID)
        
        return firestore.read(query: query)
    }
    
    func updateClass(cls: Class) -> AnyPublisher<Void, Error> {
        if let docID = cls.documentID {
            return firestore.update(collection: collection, documentId: docID, data: cls)
        } else {
            return Fail<Void, Error>(error: NSError(domain: "No document ID found", code: 0))
                .eraseToAnyPublisher()
        }
    }
    
    func deleteClass(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}
