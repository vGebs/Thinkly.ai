//
//  NoteSectionService_Firestore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-20.
//

import Foundation
import FirebaseFirestore
import Combine

//NOTE: We are going to have to make a text splitter
//       For the input we need to determine an adequate length and then split

class NoteSectionService_Firestore {
    
    static let shared = NoteSectionService_Firestore()
    
    private var firestore = FirestoreWrapper.shared
    
    private let collection = "NoteSections"
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func addSection(_ section: NoteSection) -> AnyPublisher<String, Error> {
        return firestore.create(collection: collection, data: section)
    }
    
    func getSection(with classID: String, and index: Int) -> AnyPublisher<[NoteSection], Error> {
        let query = db.collection(collection)
            .whereField("classID", isEqualTo: classID)
            .whereField("index", isEqualTo: index)
        
        return firestore.read(query: query)
    }
    
    func updateSection(_ section: NoteSection) -> AnyPublisher<Void, Error> {
        return firestore.update(collection: collection, documentId: section.documentID!, data: section)
    }
    
    func deleteSection(with docID: String) -> AnyPublisher<Void, Error> {
        return firestore.delete(collection: collection, documentId: docID)
    }
}
