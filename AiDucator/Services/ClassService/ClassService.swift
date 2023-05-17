//
//  ClassService.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine

class ClassService {
    
    static let shared = ClassService()
    
    private let firestore = ClassService_Firestore.shared
    private let cache = ThinklyModel.shared.classService
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {  }
    
    func addClass(_ cls: Class) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.firestore.addClass(cls)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ClassService: Failed to add class")
                        print("ClassService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ClassService: Successfully added class")
                    }
                } receiveValue: { [weak self] docID in
                    self?.cache.addClass(cls: cls, docID: docID)
                    promise(.success(()))
                }.store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func fetchClass(with docID: String) -> AnyPublisher<Class?, Error> {
        return Future<Class?, Error> { [weak self] promise in
            if let cls = self?.cache.fetchClass(with: docID) {
                promise(.success(cls))
            } else {
                self?.firestore.getClass(with: docID)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ClassService: Failed to fetch class")
                            print("ClassService-err: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("ClassService: Successfully fetched class")
                        }
                    } receiveValue: { [weak self] cls in
                        
                        self?.cache.updateClass(cls: cls)
                        
                        promise(.success(cls))
                    }.store(in: &self!.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchClasses(for teacherID: String) -> AnyPublisher<[Class]?, Error> {
        return Future<[Class]?, Error> { [weak self] promise in
            if let clsArray = self?.cache.fetchClasses(for: teacherID), !clsArray.isEmpty {
                var hasAllDocIds = true
                for cls in clsArray {
                    if cls.documentID == nil {
                        hasAllDocIds = false
                    }
                }
                
                if hasAllDocIds {
                    promise(.success(clsArray))
                } else {
                    self?.firestore.getClasses(for: teacherID)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("ClassService: Failed to fetch classes")
                                print("ClassService-err: \(e)")
                                promise(.failure(e))
                            case .finished:
                                print("ClassService: Successfully fetched classes")
                            }
                        } receiveValue: { clsArray in
                            if !clsArray.isEmpty {
                                for cls in clsArray {
                                    self?.cache.updateClass(cls: cls)
                                }
                            }
                            promise(.success(clsArray))
                        }.store(in: &self!.cancellables)
                }
            } else {
                self?.firestore.getClasses(for: teacherID)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ClassService: Failed to fetch classes")
                            print("ClassService-err: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("ClassService: Successfully fetched classes")
                        }
                    } receiveValue: { clsArray in
                        if !clsArray.isEmpty {
                            for cls in clsArray {
                                self?.cache.updateClass(cls: cls)
                            }
                        }
                        promise(.success(clsArray))
                    }.store(in: &self!.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func updateClass(_ cls: Class) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.firestore.updateClass(cls: cls)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ClassService: Failed to update class")
                        print("ClassService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ClassService: Successfully updated class")
                    }
                } receiveValue: { [weak self] _ in
                    self?.cache.updateClass(cls: cls)
                    promise(.success(()))
                }.store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func deleteClass(docID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.firestore.deleteClass(docID: docID)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ClassService: Failed to delete class")
                        print("ClassService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ClassService: Successfully deleted class")
                    }
                } receiveValue: { [weak self] _ in
                    self?.cache.deleteClass(with: docID)
                    promise(.success(()))
                }.store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
}

