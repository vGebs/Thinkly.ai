//
//  File.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine
import FirebaseFirestore

class CourseService_Firestore {
    
    static let shared = CourseService_Firestore()
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "Courses"
    
    private let db = Firestore.firestore()
    
    private init() {  }
    
    func addCourse(_ cls: Course) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: cls)
    }
    
    func getCourse(with docID: String) -> AnyPublisher<Course, Error> {
        return firestore.read(collection: collection, documentId: docID)
    }
    
    func getCourses(for teacherID: String) -> AnyPublisher<[Course], Error> {
        
        let query: Query = db.collection(collection).whereField("teacherID", isEqualTo: teacherID)
        
        return firestore.read(query: query)
    }
    
    func updateCourse(course: Course) -> AnyPublisher<Void, Error> {
        if let docID = course.documentID {
            return firestore.update(collection: collection, documentId: docID, data: course)
        } else {
            return Fail<Void, Error>(error: NSError(domain: "No document ID found", code: 0))
                .eraseToAnyPublisher()
        }
    }
    
    func deleteCourse(docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
    
    func listenOnCourse(with docID: String) -> AnyPublisher<(Course, DocumentChangeType), Error> {
        return firestore.listenByDocument(collection: collection, documentId: docID)
    }
    
    func listenOnCourses(for teacherID: String) -> AnyPublisher<[(Course, DocumentChangeType)], Error> {
        let query: Query = db.collection(collection).whereField("teacherID", isEqualTo: teacherID)
        return firestore.listenByQuery(query: query)
    }
}
