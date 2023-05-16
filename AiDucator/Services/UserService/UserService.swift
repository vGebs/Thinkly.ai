//
//  UserService.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import Combine

class UserService {
    
    static let shared = UserService()
    
    let firestore = UserService_Firestore.shared
    let cache = ThinklyModel.shared.userService
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {  }
    
    func createUser(_ user: User) -> AnyPublisher<Void, Error> {
        //we need to push to the database, if success, push to cache
        return Future<Void, Error> { [weak self] promise in
            self?.firestore.createUser(user)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserService: Failed to create user")
                        print("UserService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserService: Successfully created user")
                    }
                } receiveValue: { [weak self] docID in
                    self?.cache.createUser(user, docID: docID)
                    promise(.success(()))
                }.store(in: &self!.cancellables)
            
        }.eraseToAnyPublisher()
    }
    
    func fetchUser(with uid: String) -> AnyPublisher<User?, Error> {
        //we need to check the cache, if its there and it has a docID, return it, otherwise fetch db
        //
        return Future<User?, Error> { [weak self] promise in
            if let user = self!.cache.fetchUser(uid: uid), user.documentID != nil{
                promise(.success(user))
            } else {
                self?.firestore.fetchUser(with: uid)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("UserService: Failed to fetch user")
                            print("UserService-err: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("UserService: Successfully fetched user")
                        }
                    } receiveValue: { user in
                        if let fetchtedUser = user {
                            self!.cache.updateUser(user: fetchtedUser)
                        }
                        promise(.success(user))
                    }.store(in: &self!.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func updateName(_ user: User, docID: String) -> AnyPublisher<Void, Error> {
        //we need to push to db first, if success, we push to cache
        return Future<Void, Error> { [weak self] promise in
            self?.firestore.updateName(user, docID: docID)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserService: Failed to update name of user")
                        print("UserService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserService: Successfully updated name of user")
                    }
                } receiveValue: { [weak self] _ in
                    self?.cache.updateUser(user: user)
                    promise(.success(()))
                }.store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func deleteUser(user: User) -> AnyPublisher<Void, Error> {
        //we want to remove the user from the db then from the cache
        return Future<Void, Error> { [weak self] promise in
            if let docID = user.documentID {
                self?.firestore.deleteUser(docID: docID)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("UserService: Failed to delete user")
                            print("UserService-err: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("UserService: Finished deleting user")
                        }
                    } receiveValue: { [weak self] _ in
                        self!.cache.deleteUser(uid: user.uid)
                        promise(.success(()))
                    }.store(in: &self!.cancellables)
            } else {
                print("UserService: DocID is nil")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
