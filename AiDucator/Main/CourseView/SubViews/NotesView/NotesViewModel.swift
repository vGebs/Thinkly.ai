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
    @Published var submittedSubUnits: Set<Int> = []
    
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
        
        var c = self.curriculum
        c.units[index].subUnits = nil
        
        if submittedSubUnits.contains(index) {
            self.trashSubUnits(with: index, regenerating: true)
        }
        
        CourseCreationService().getSubUnits(GetSubUnits(unitNumber: index + 1, curriculum: c.units))
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
                if subUnits.subUnits.count != 0 {
                    self?.curriculum.units[index].subUnits = subUnits.subUnits
                }
                self?.loadingIndexes.remove(index)
            }.store(in: &cancellables)
    }
    
    func submitUnits(with index: Int) {
        UnitService_firestore.shared.pushSubUnits(units: curriculum.units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to push sub units")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished pushing sub units")
                }
            } receiveValue: { [weak self] _ in
                self?.submittedSubUnits.insert(index)
            }
            .store(in: &cancellables)
    }
    
    func trashSubUnits(with index: Int, regenerating: Bool = false) {
        self.loadingIndexes.insert(index)
        self.curriculum.units[index].subUnits = nil
        
        UnitService_firestore.shared.pushSubUnits(units: curriculum.units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to trash sub units")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished trashing sub units")
                }
            } receiveValue: { [weak self] _ in
                if !regenerating {
                    self?.loadingIndexes.remove(index)
                }
                self?.submittedSubUnits.remove(index)
            }
            .store(in: &cancellables)
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
                    for i in 0..<self!.curriculum.units.count {
                        if self?.curriculum.units[i].subUnits != nil {
                            self?.submittedSubUnits.insert(i)
                        }
                    }
                }
            }.store(in: &cancellables)
    }
}
