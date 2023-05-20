//
//  NotesService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-20.
//

import Foundation
import Combine
import FirebaseFirestore

class NotesService_Firestore {
    
    static let shared = NotesService_Firestore()
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "Notes"
    
    private let db = Firestore.firestore()
    
    private init() {  }
    
    func addNotes(_ notes: Notes) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: notes)
    }
    
    func getNotes(docID: String) -> AnyPublisher<Notes, Error> {
        return firestore.read(collection: collection, documentId: docID)
    }
    
    func getNotes(for classID: String) -> AnyPublisher<[Notes], Error> {
        let query = db.collection(collection).whereField("classID", isEqualTo: classID)
        
        return firestore.read(query: query)
    }
    
    func listenOnNotes(for classID: String) -> AnyPublisher<[(Notes, DocumentChangeType)], Error> {
        let query = db.collection(collection).whereField("classID", isEqualTo: classID)
        
        return firestore.listenByQuery(query: query)
    }
    
    func updateNotes(notes: Notes) -> AnyPublisher<Void, Error> {
        return firestore.update(collection: collection, documentId: notes.documentID!, data: notes)
    }
    
    func deleteNotes(with docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}
