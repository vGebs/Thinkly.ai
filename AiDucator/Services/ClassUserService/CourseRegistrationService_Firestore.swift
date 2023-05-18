//
//  ClassUserService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import Combine
import FirebaseFirestore

class CourseRegistrationService_Firestore {
    
    private let firestore = FirestoreWrapper.shared
    
    private let collection = "CourseRegistration"
    private let db = Firestore.firestore()
    
    static let shared = CourseRegistrationService_Firestore()
    
    private init() {  }
    
    func joinCourse(courseReg: CourseRegristration) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: courseReg)
    }
    
    func getRegristrations(for uid: String) -> AnyPublisher<[CourseRegristration], Error> {
        let query: Query = db.collection(collection).whereField("userID", isEqualTo: uid)
        return firestore.read(query: query)
    }
    
    func dropCourse(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
    
    func listenOnRegristrations(for uid: String) -> AnyPublisher<[(CourseRegristration, DocumentChangeType)], Error> {
        let query: Query = db.collection(collection).whereField("userID", isEqualTo: uid)
        return firestore.listenByQuery(query: query)
    }
}
