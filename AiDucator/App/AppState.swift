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
    
    @Published var billing = InAppPurchasesService(productIdentifiers: ["com.brickSquad.thinklyPremium"], entitlementManager: EntitlementManager())
    
    @Published var backend_BaseUrl: URL?
    
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
                    self?.fetchBackendURL()
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
    
    func deleteCourse(courseDocID: String) {
        deleteCourse(id: courseDocID)
        deleteUnits(courseID: courseDocID)
        deleteAssignments(courseID: courseDocID)
        deleteNotes(courseID: courseDocID)
    }
}

import Firebase
import FirebaseFirestoreSwift

extension AppState {
    private func fetchBackendURL() {
        fetchBackendURL_()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("AppState: Failed to fetch base URL")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: Finished fetching URL")
                }
            } receiveValue: { [weak self] (url, docChange) in
                let fullURL = "http://" + url.baseURL
                self?.backend_BaseUrl = URL(string: fullURL)
                print("BaseURL-String: ")
                print(self?.backend_BaseUrl)
            }.store(in: &cancellables)
    }
    
    struct BackendURL: FirestoreProtocol {
        @DocumentID var documentID: String?
        var baseURL: String
    }
    
    private func fetchBackendURL_() -> AnyPublisher<(BackendURL,DocumentChangeType), Error> {
        return FirestoreWrapper.shared.listenByDocument(collection: "BackendURL", documentId: "url")
    }
}

extension AppState {
    private func deleteCourse(id: String) {
        CourseService_Firestore.shared.deleteCourse(docID: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("AppState: Failed to delete course")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: Finished deleting course")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func deleteUnits(courseID: String) {
        //we need to fetch the units then delete it given the docID
        UnitService_firestore.shared.fetchUnits(courseID: courseID)
            .flatMap { curriculums -> AnyPublisher<Void, Error> in
                let publishers = curriculums.map { curriculum in
                    return UnitService_firestore.shared.deleteUnit(docID: curriculum.documentID!)
                }
                return Publishers.MergeMany(publishers).eraseToAnyPublisher()
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("AppState: Successfully deleted all units.")
                case .failure(let error):
                    print("AppState: Failed to delete units")
                    print("AppState-err: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func deleteAssignments(courseID: String) {
        //we need to fetch the assignments and delete them given the docID
        AssignmentService_Firestore.shared.fetchAssignments(courseID: courseID)
            .flatMap { assignments -> AnyPublisher<Void, Error> in
                let publishers = assignments.map { a in
                    return AssignmentService_Firestore.shared.deleteAssignment(docID: a.documentID!)
                }
                return Publishers.MergeMany(publishers).eraseToAnyPublisher()
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("AppState: Successfully deleted all assignments.")
                case .failure(let error):
                    print("AppState: Failed to delete assignments")
                    print("AppState-err: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func deleteNotes(courseID: String) {
        //we need to fetch the notes and delete them given the docID
        NotesService_Firestore.shared.getNotes(courseID: courseID)
            .flatMap { notes -> AnyPublisher<Void, Error> in
                let publishers = notes.map { note in
                    return NotesService_Firestore.shared.deleteNotes(with: note.documentID!)
                }
                return Publishers.MergeMany(publishers).eraseToAnyPublisher()
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("AppState: Successfully deleted all notes.")
                case .failure(let error):
                    print("AppState: Failed to delete notes")
                    print("AppState-err: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
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
                
                self?.user = User(
                    documentID: u.documentID!,
                    name: u.name,
                    uid: u.uid,
                    birthdate: u.birthdate
                )
                
                // 2. Determine if user is a teacher or student
                self?.observeClasses(for: u.uid)
//                if u.role == "teacher" {
//                    // 3a. Fetch classes for teacher
//                    self?.observeClasses(for: u.uid)
//                } else {
//                    // 3b. Fetch ClassUser documents for student, then fetch associated classes
//                    self?.observeClassesForStudent(uid: uid)
//                }
                self?.loading = false
            }).store(in: &cancellables)
    }
    
    private func observeClasses(for uid: String) {
        CourseService_Firestore.shared.listenOnCourses(for: uid)
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
        //ThinklyModel.shared.courseService.clearCache()
    }
}

extension AppState {
    func updatePurchasedProducts() async {
        await billing.updatePurchasedProducts()
    }
}
