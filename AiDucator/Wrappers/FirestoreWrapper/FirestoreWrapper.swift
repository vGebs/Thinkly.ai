//
//  FirestoreWrapper.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

public protocol FirestoreProtocol: Codable {
    var documentID: String? { get set }
}

public class FirestoreWrapper {
    public static let shared = FirestoreWrapper()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    public func create<T: Encodable>(collection: String, data: T) -> AnyPublisher<String, Error> {
        return Future<String, Error> { [weak self] promise in
            do {
                let docRef = try self?.db.collection(collection).addDocument(from: data)
                promise(.success(docRef!.documentID))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    public func read<T: FirestoreProtocol>(collection: String, documentId: String) -> AnyPublisher<T, Error> {
        return Future<T, Error> { [weak self] promise in
            self?.db.collection(collection).document(documentId).getDocument { (snapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    do {
                        let object = try snapshot!.data(as: T.self)
                        promise(.success(object))
                    } catch let error {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Read multiple documents
    public func read<T: FirestoreProtocol>(query: Query) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    do {
                        let values = try snapshot?.documents.compactMap {
                            let data = try $0.data(as: T.self)
                            return data
                        }
                        promise(.success(values ?? []))
                    } catch let error {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    // Update a single document
    public func update<T: Encodable>(collection: String, documentId: String, data: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            let encoder = Firestore.Encoder()
            self?.db.collection(collection).document(documentId).setData(try! encoder.encode(data), merge: true) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Delete a single document
    public func delete(collection: String, documentId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection(collection).document(documentId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func listenByDocument<T: FirestoreProtocol>(collection: String, documentId: String) -> AnyPublisher<(T, DocumentChangeType), Error> {
        let publisher = DocumentSnapshotPublisher<T>(db.collection(collection).document(documentId))
        return publisher.mapError { $0 }.eraseToAnyPublisher()
    }
    
    public func listenByQuery<T: FirestoreProtocol>(query: Query) -> AnyPublisher<[(T, DocumentChangeType)], Error> {
        let publisher = QuerySnapshotPublisher<T>(query)
        return publisher.mapError { $0 }.eraseToAnyPublisher()
    }
}
