//
//  ClassListViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import Combine

class CourseListViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var newCls: Course?
    
    private var cancellables: [AnyCancellable] = []
    
    @Published var loading = true
    
    init() {
        self.fetchClasses(for: AuthService.shared.user!.uid)
    }
    
    func addCourse(title: String, sfSymbol: String, description: String, startDate: Date, endDate: Date) {
        
        let course = Course(title: title, sfSymbol: sfSymbol, description: description, startDate: startDate, endDate: endDate, teacherID: AuthService.shared.user!.uid)
        
        CourseService_Firestore.shared.addCourse(course)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ClassListViewModel: Failed to add a new class for user")
                    print("ClassListViewModel-err: \(e)")
                case .finished:
                    print("ClassListViewModel: Finished adding new class for user")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    deinit {
        for i in 0..<self.cancellables.count {
            self.cancellables[i].cancel()
        }
    }
}

extension CourseListViewModel {
    private func fetchClasses(for uid: String) {
        // 1. Fetch user
        UserService_Firestore.shared.fetchUser(with: uid)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] userFirestore in
                guard let u = userFirestore else {
                    print("User not found")
                    return
                }
                
                self?.user = User(documentID: u.documentID!,
                                  name: u.name,
                                  role: u.role,
                                  uid: u.uid,
                                  birthdate: u.birthdate)
                
                // 2. Determine if user is a teacher or student
                if u.role == "teacher" {
                    // 3a. Fetch classes for teacher
                    self?.observeClasses(for: u.uid)
                } else {
                    // 3b. Fetch ClassUser documents for student, then fetch associated classes
                    self?.observeClassesForStudent(uid: uid)
                }
                self?.loading = false
            }).store(in: &cancellables)
    }
    
    private func observeClasses(for teacherID: String) {
        CourseService_Firestore.shared.listenOnCourses(for: teacherID)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ClassListViewModel: Failed to observe classes")
                    print("ClassListViewModel-err: \(e)")
                case .finished:
                    print("ClassListViewModel: observed classes")
                }
            } receiveValue: { [weak self] classes in
                for cls in classes {
                    switch cls.1 {
                    case .added:
                        //add to classes
                        if let _ = self?.user {
                            if let _ = self!.user!.courses {
                                self!.user!.courses?.append(cls.0)
                            } else {
                                self!.user?.courses = [cls.0]
                            }
                        }
                    case .modified:
                        if let _ = self?.user {
                            if let _ = self!.user!.courses {
                                for i in 0..<self!.user!.courses!.count {
                                    if cls.0.documentID == self!.user!.courses![i].documentID {
                                        self!.user!.courses![i] = cls.0
                                        break
                                    }
                                }
                            } else {
                                self!.user?.courses = [cls.0]
                            }
                        }
                    case .removed:
                        if let _ = self?.user {
                            if let _ = self!.user!.courses {
                                for i in 0..<self!.user!.courses!.count {
                                    if cls.0.documentID == self!.user!.courses![i].documentID {
                                        self!.user!.courses!.remove(at: i)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellables)
        
    }
    
    //classID == docID
    private func observeClass(classID: String) {
        CourseService_Firestore.shared.listenOnCourse(with: classID)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ClassListViewModel: Failed to observe class")
                    print("ClassListViewModel-err: \(e)")
                case .finished:
                    print("ClassListViewModel: observed class")
                }
            } receiveValue: { [weak self] cls in
                
                switch cls.1 {
                case .added:
                    //add to classes
                    if let _ = self?.user {
                        if let _ = self!.user!.courses {
                            self!.user!.courses?.append(cls.0)
                        } else {
                            self!.user?.courses = [cls.0]
                        }
                    }
                case .modified:
                    if let _ = self?.user {
                        if let _ = self!.user!.courses {
                            for i in 0..<self!.user!.courses!.count {
                                if cls.0.documentID == self!.user!.courses![i].documentID {
                                    self!.user!.courses![i] = cls.0
                                    break
                                }
                            }
                        } else {
                            self!.user?.courses = [cls.0]
                        }
                    }
                case .removed:
                    if let _ = self?.user {
                        if let _ = self!.user!.courses {
                            for i in 0..<self!.user!.courses!.count {
                                if cls.0.documentID == self!.user!.courses![i].documentID {
                                    self!.user!.courses!.remove(at: i)
                                    break
                                }
                            }
                        }
                    }
                }
                
            }.store(in: &cancellables)
    }
    
    private func observeClassesForStudent(uid: String) {
        CourseRegistrationService_Firestore.shared.listenOnRegristrations(for: uid)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ClassListViewModel: Failed to observe ClassUser for uid")
                    print("ClassListViewModel-err: \(e)")
                case .finished:
                    print("ClassListViewModel: observed ClassUser")
                }
            } receiveValue: { [weak self] classes in
                for cls in classes {
                    switch cls.1 {
                    case .added:
                        self!.observeClass(classID: cls.0.documentID!)
                    case .modified:
                        print("This object cannot be modified")
                    case .removed:
                        //remove the class from the user classes
                        if let _ = self?.user {
                            if let _ = self!.user!.courses {
                                for i in 0..<self!.user!.courses!.count {
                                    if cls.0.courseID == self!.user!.courses![i].documentID! {
                                        self!.user!.courses?.remove(at: i)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellables)
    }
}

extension CourseListViewModel {
    func clearCache() {
        ThinklyModel.shared.courseService.clearCache()
    }
    
    func logout() {
        AuthService.shared.logout()
    }
}
