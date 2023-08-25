//
//  AssignmentService_Firestore.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-10.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class AssignmentService_Firestore {
    
    static let shared = AssignmentService_Firestore()
    
    private init() {}
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "Assignments"
    
    private let db = Firestore.firestore()
    
    func pushAssignment(assignment: Assignment_Firestore) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: assignment)
    }
    
    func fetchAssignment(courseID: String, subunitNumber: Double) -> AnyPublisher<[Assignment_Firestore], Error>{
        let query = db.collection(collection).whereField("courseID", isEqualTo: courseID).whereField("subunitNumber", isEqualTo: subunitNumber)
        return firestore.read(query: query)
    }
    
    func fetchAssignments(courseID: String) -> AnyPublisher<[Assignment_Firestore], Error> {
        let query = db.collection(collection).whereField("courseID", isEqualTo: courseID)
        return firestore.read(query: query)
    }
    
    func deleteAssignment(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}

struct Assignment_Firestore: FirestoreProtocol {
    @DocumentID var documentID: String?
    var assignment: Assignment
    var courseID: String
    var subunitNumber: Double
}
