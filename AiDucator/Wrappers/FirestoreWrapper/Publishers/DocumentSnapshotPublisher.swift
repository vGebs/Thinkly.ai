//
//  DocumentSnapshotPublisher.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class DocumentSnapshotPublisher<T: FirestoreProtocol>: Publisher {
    typealias Output = (T, DocumentChangeType)
    typealias Failure = Error

    private let documentReference: DocumentReference
    private var listener: ListenerRegistration?

    init(_ documentReference: DocumentReference) {
        self.documentReference = documentReference
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = DocumentSnapshotSubscription(subscriber: subscriber, documentReference: documentReference, publisher: self)
        subscriber.receive(subscription: subscription)
    }

    private final class DocumentSnapshotSubscription<S: Subscriber>: Subscription where S.Input == (T, DocumentChangeType), S.Failure == Error {

        private var subscriber: S?
        private let documentReference: DocumentReference
        private let publisher: DocumentSnapshotPublisher<T>

        init(subscriber: S, documentReference: DocumentReference, publisher: DocumentSnapshotPublisher<T>) {
            self.subscriber = subscriber
            self.documentReference = documentReference
            self.publisher = publisher
        }

        func request(_ demand: Subscribers.Demand) {
            publisher.listener = documentReference.addSnapshotListener { (snapshot, error) in
                if let error = error {
                    self.subscriber?.receive(completion: .failure(error))
                } else {
                    do {
                        if let snap = snapshot {
                            
                            let object = try snap.data(as: T.self)
                            if snap.exists {
                                _ = self.subscriber?.receive((object, .modified))
                            } else {
                                _ = self.subscriber?.receive((object, .removed))
                            }
                        }
                    } catch let error {
                        self.subscriber?.receive(completion: .failure(error))
                    }
                }
            }
        }

        func cancel() {
            publisher.listener?.remove()
            subscriber = nil
        }
    }
}
