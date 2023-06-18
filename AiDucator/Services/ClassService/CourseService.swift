//
//  CourseService.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine

//class CourseService {
//
//    static let shared = CourseService()
//
//    private let firestore = CourseService_Firestore.shared
//    private let cache = ThinklyModel.shared.courseService
//
//    private var cancellables: [AnyCancellable] = []
//
//    private init() {  }
//
//    func addCourse(_ course: Course) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { [weak self] promise in
//            self?.firestore.addCourse(course)
//                .sink { completion in
//                    switch completion {
//                    case .failure(let e):
//                        print("CourseService: Failed to add course")
//                        print("CourseService-err: \(e)")
//                        promise(.failure(e))
//                    case .finished:
//                        print("CourseService: Successfully added course")
//                    }
//                } receiveValue: { [weak self] docID in
//                    self?.cache.addCourse(course: course, docID: docID)
//                    promise(.success(()))
//                }.store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//
//    func fetchCourse(with docID: String) -> AnyPublisher<Course?, Error> {
//        return Future<Course?, Error> { [weak self] promise in
//            if let course = self?.cache.fetchCourse(with: docID) {
//                promise(.success(course))
//            } else {
//                self?.firestore.getCourse(with: docID)
//                    .sink { completion in
//                        switch completion {
//                        case .failure(let e):
//                            print("CourseService: Failed to fetch course")
//                            print("CourseService-err: \(e)")
//                            promise(.failure(e))
//                        case .finished:
//                            print("CourseService: Successfully fetched course")
//                        }
//                    } receiveValue: { [weak self] course in
//
//                        self?.cache.updateCourse(course: course)
//
//                        promise(.success(course))
//                    }.store(in: &self!.cancellables)
//            }
//        }.eraseToAnyPublisher()
//    }
//
//    func fetchCourses(for teacherID: String) -> AnyPublisher<[Course]?, Error> {
//        return Future<[Course]?, Error> { [weak self] promise in
//            if let courseArray = self?.cache.fetchCourses(for: teacherID), !courseArray.isEmpty {
//                var hasAllDocIds = true
//                for course in courseArray {
//                    if course.documentID == nil {
//                        hasAllDocIds = false
//                    }
//                }
//
//                if hasAllDocIds {
//                    promise(.success(courseArray))
//                } else {
//                    self?.firestore.getCourses(for: teacherID)
//                        .sink { completion in
//                            switch completion {
//                            case .failure(let e):
//                                print("CourseService: Failed to fetch courses")
//                                print("CourseService-err: \(e)")
//                                promise(.failure(e))
//                            case .finished:
//                                print("CourseService: Successfully fetched courses")
//                            }
//                        } receiveValue: { courseArray in
//                            if !courseArray.isEmpty {
//                                for course in courseArray {
//                                    self?.cache.updateCourse(course: course)
//                                }
//                            }
//                            promise(.success(courseArray))
//                        }.store(in: &self!.cancellables)
//                }
//            } else {
//                self?.firestore.getCourses(for: teacherID)
//                    .sink { completion in
//                        switch completion {
//                        case .failure(let e):
//                            print("CourseService: Failed to fetch courses")
//                            print("CourseService-err: \(e)")
//                            promise(.failure(e))
//                        case .finished:
//                            print("CourseService: Successfully fetched courses")
//                        }
//                    } receiveValue: { courseArray in
//                        if !courseArray.isEmpty {
//                            for course in courseArray {
//                                self?.cache.updateCourse(course: course)
//                            }
//                        }
//                        promise(.success(courseArray))
//                    }.store(in: &self!.cancellables)
//            }
//        }.eraseToAnyPublisher()
//    }
//
//    func updateCourse(_ course: Course) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { [weak self] promise in
//            self?.firestore.updateCourse(course: course)
//                .sink { completion in
//                    switch completion {
//                    case .failure(let e):
//                        print("CourseService: Failed to update course")
//                        print("CourseService-err: \(e)")
//                        promise(.failure(e))
//                    case .finished:
//                        print("CourseService: Successfully updated course")
//                    }
//                } receiveValue: { [weak self] _ in
//                    self?.cache.updateCourse(course: course)
//                    promise(.success(()))
//                }.store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//    
//    func deleteCourse(docID: String) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { [weak self] promise in
//            self?.firestore.deleteCourse(docID: docID)
//                .sink { completion in
//                    switch completion {
//                    case .failure(let e):
//                        print("CourseService: Failed to delete course")
//                        print("CourseService-err: \(e)")
//                        promise(.failure(e))
//                    case .finished:
//                        print("CourseService: Successfully deleted course")
//                    }
//                } receiveValue: { [weak self] _ in
//                    self?.cache.deleteCourse(with: docID)
//                    promise(.success(()))
//                }.store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//}
//
