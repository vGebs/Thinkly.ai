//
//  NotesViewModel.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-18.
//

import Foundation
import Combine

class NotesViewModel: ObservableObject {
    
    @Published var curriculum: Curriculum = Curriculum(units: [])
    
    private var cancellables: [AnyCancellable] = []
    
    init(courseDef: CourseOverview?) {
        if let c = courseDef {
            self.fetchCurriculum(courseID: c.documentID!)
        }
    }
    
    deinit {
        print("NotesViewModel: Deinitialized")
    }
}

extension NotesViewModel {
    private func fetchCurriculum(courseID: String) {
        UnitService_firestore.shared.fetchUnits(courseID: courseID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to fetch curriculum")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished fetching curriculum")
                }
            } receiveValue: { [weak self] curriculums in
                if curriculums.count > 0 {
                    self?.curriculum = curriculums[0]
                }
            }.store(in: &cancellables)
    }
}
