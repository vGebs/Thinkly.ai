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
    
    @Published var loadingIndexes: Set<Int> = []
    
    init(courseDef: CourseOverview?) {
        if let c = courseDef {
            self.fetchCurriculum(courseID: c.documentID!)
        }
    }
    
    deinit {
        print("NotesViewModel: Deinitialized")
    }
    
    func generateSubUnits(with index: Int) {
        self.loadingIndexes.insert(index)
        CourseCreationService().getSubUnits(GetSubUnits(unitNumber: index + 1, curriculum: curriculum.units))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get subunits")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished generating sub units for unit index: \(index)")
                }
            } receiveValue: { [weak self] subUnits in
                self?.curriculum.units[index].subUnits = subUnits.subUnits
                self?.loadingIndexes.remove(index)
            }.store(in: &cancellables)
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
