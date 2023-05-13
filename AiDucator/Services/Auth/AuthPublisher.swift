//
//  AuthPublisher.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import FirebaseAuth
import Combine

class AuthStatePublisher: Combine.Publisher {
    typealias Output = Auth
    typealias Failure = Never

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let listenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            _ = subscriber.receive(auth)
        }
        subscriber.receive(subscription: AuthStateSubscription(listenerHandle: listenerHandle))
    }
}

private final class AuthStateSubscription: Subscription {
    private let listenerHandle: AuthStateDidChangeListenerHandle

    init(listenerHandle: AuthStateDidChangeListenerHandle) {
        self.listenerHandle = listenerHandle
    }

    func request(_ demand: Subscribers.Demand) {
        // The demand is ignored since this publisher only emits one value
    }

    func cancel() {
        Auth.auth().removeStateDidChangeListener(listenerHandle)
    }
}
