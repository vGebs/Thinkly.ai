//
//  ClassListViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import Combine

class CourseListViewModel: ObservableObject {
    
    private var cancellables: [AnyCancellable] = []
    
    @Published var courses: [Course]?
    
    init() {
        AppState.shared.$user
            .sink { [weak self] user in
                if let u = user {
                    self?.courses = u.courses
                }
            }.store(in: &cancellables)
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
    
    func enrollInCourse(id: String) {
        CourseRegistrationService_Firestore.shared.joinCourse(courseReg: CourseRegristration(courseID: id, userID: AuthService.shared.user!.uid))
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("CourseListViewModel: Failed to register for course")
                    print("CourseListViewModel-err: \(e)")
                case .finished:
                    print("CourseListViewModel: Finished registering for course")
                }
            } receiveValue: { docID in
                print("DocID")
            }.store(in: &cancellables)
    }
    
    deinit {
        for i in 0..<self.cancellables.count {
            self.cancellables[i].cancel()
        }
    }
}
