//
//  NotesService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-20.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class NotesService_Firestore {
    
    static let shared = NotesService_Firestore()
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "Notes"
    
    private let db = Firestore.firestore()
    
    private init() {  }
    
    func addNotes(_ notes: Notes_Firestore) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: notes)
    }
    
    func getNotes(docID: String) -> AnyPublisher<Notes_Firestore, Error> {
        return firestore.read(collection: collection, documentId: docID)
    }

    func getNotes(for classID: String) -> AnyPublisher<[Notes_Firestore], Error> {
        let query = db.collection(collection).whereField("classID", isEqualTo: classID)

        return firestore.read(query: query)
    }

    func listenOnNotes(for classID: String) -> AnyPublisher<[(Notes_Firestore, DocumentChangeType)], Error> {
        let query = db.collection(collection).whereField("classID", isEqualTo: classID)

        return firestore.listenByQuery(query: query)
    }

    func updateNotes(notes: Notes_Firestore) -> AnyPublisher<Void, Error> {
        return firestore.update(collection: collection, documentId: notes.documentID!, data: notes)
    }
    
    func deleteNotes(with docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}

struct Notes_Firestore: Codable, FirestoreProtocol {
    @DocumentID var documentID: String?
    var notes: Notes
    var lessonNumber: String
    var courseID: String
}
