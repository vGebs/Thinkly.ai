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
    
    deinit {
        for i in 0..<self.cancellables.count {
            self.cancellables[i].cancel()
        }
    }
}
