//
//  AppState.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-08.
//

import Foundation
import Combine

class AppState: ObservableObject {
    
    static let shared = AppState()
    
    @Published private(set) var user: User?
    
    @Published var loading = true
    
    @Published var onLandingView = true
    @Published var onLoginView = false
    @Published var onSignupView = false
    
    @Published var onMainView = false
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        
        $onLandingView
            .sink { [weak self] onLoginSignup in
                if onLoginSignup {
                    self?.onLoginView = false
                    self?.onSignupView = false
                }
            }.store(in: &cancellables)
        
        $onLoginView
            .sink { [weak self] onLogin in
                if onLogin {
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        $onSignupView
            .sink { [weak self] onSignup in
                if onSignup {
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        $onMainView
            .sink { [weak self] onMain in
                if onMain {
                    self?.onLoginView = false
                    self?.onSignupView = false
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        Publishers.CombineLatest3($onMainView, $onLoginView, $onSignupView)
            .flatMap { (onMain, onLogin, onSignup) -> AnyPublisher<Bool, Never> in
                if !onMain && !onLogin && !onSignup {
                    return Just(true).eraseToAnyPublisher()
                } else {
                    return Just(false).eraseToAnyPublisher()
                }
            }.assign(to: &$onLandingView)
        
        AuthService.shared.$user
            .sink { [weak self] user in
                if let u = user {
                    self?.onMainView = true
                    self?.fetchClasses(for: u.uid)
                }
            }.store(in: &cancellables)
    }
    
    func logout() {
        AuthService.shared.signOut()
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("AppState: Failed to logout")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: Logged out")
                }
            } receiveValue: { [weak self] _ in
                AppState.shared.onMainView = false
                AppState.shared.onLandingView = true
                self?.user = nil
            }.store(in: &cancellables)
    }
}

extension AppState {
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
                    print("AppState: Failed to observe classes")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: observed classes")
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
                    print("AppState: Failed to observe class")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: observed class")
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
                    print("AppState: Failed to observe ClassUser for uid")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: observed ClassUser")
                }
            } receiveValue: { [weak self] classes in
                for cls in classes {
                    switch cls.1 {
                    case .added:
                        self!.observeClass(classID: cls.0.courseID)
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

extension AppState {
    func clearCache() {
        ThinklyModel.shared.courseService.clearCache()
    }
}
