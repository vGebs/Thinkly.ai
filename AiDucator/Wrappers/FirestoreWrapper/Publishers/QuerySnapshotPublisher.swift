//
//  QuerySnapshotPublisher.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class QuerySnapshotPublisher<T: FirestoreProtocol>: Publisher {

    typealias Output = [(T, DocumentChangeType)]
    typealias Failure = Error

    private let query: Query
    private var listener: ListenerRegistration?

    init(_ query: Query) {
        self.query = query
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = QuerySnapshotSubscription(subscriber: subscriber, query: query, publisher: self)
        subscriber.receive(subscription: subscription)
    }

    private final class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == [(T, DocumentChangeType)], S.Failure == Error {

        private var subscriber: S?
        private let query: Query
        private let publisher: QuerySnapshotPublisher<T>

        init(subscriber: S, query: Query, publisher: QuerySnapshotPublisher<T>) {
            self.subscriber = subscriber
            self.query = query
            self.publisher = publisher
        }

        func request(_ demand: Subscribers.Demand) {
            publisher.listener = query.addSnapshotListener { (snapshot, error) in
                if let error = error {
                    self.subscriber?.receive(completion: .failure(error))
                } else {
                    do {
                        if let snap = snapshot {
                            var values: [(T, DocumentChangeType)] = []
                            for change in snap.documentChanges {
                                let object = try change.document.data(as: T.self)
                                values.append((object, change.type))
                            }
                            _ = self.subscriber?.receive(values)
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
