//
//  NotesViewModel.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-18.
//

import Foundation
import Combine
import SwiftUI

class NotesViewModel: ObservableObject {
    
    @Published var curriculum: Curriculum = Curriculum(units: [])
    @Published var submittedSubUnits: Set<Int> = []
    @Published var submittedLessons: Set<Double> = []
    
    @Published var showRegenerateSubUnits: Set<Int> = []
    
    private var cancellables: [AnyCancellable] = []
    
    @Published var loadingIndexes: Set<Int> = []
    
    init(courseDef: CourseOverview? = nil, dummyClass: Bool = false) {
        if !dummyClass {
            if let c = courseDef {
                self.fetchCurriculum(courseID: c.documentID!)
            }
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
    
    @Published var loadingIndexes_lessons: Set<Double> = []
    
    func generateLessons(subunitNumber: Double) {
        loadingIndexes_lessons.insert(subunitNumber)
        showRegenerateSubUnits.insert(Int(subunitNumber))
        
        for i in 0..<self.curriculum.units.count {
            for j in 0..<self.curriculum.units[i].subUnits!.count {
                if self.curriculum.units[i].subUnits![j].unitNumber == subunitNumber {
                    if self.curriculum.units[i].subUnits![j].lessons != nil {
                        withAnimation {
                            self.curriculum.units[i].subUnits![j].lessons = nil
                            self.trashLessons(with: i, and: j)
                        }
                    }
                    break
                }
            }
        }
        
        CourseCreationService().generateLessonsForSubunit(GetLessons(curriculum: self.curriculum.units, subunitNumber: subunitNumber))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: failed to generate lessons")
                    print("NotesViewModel-err: \(e)")
                    self?.loadingIndexes_lessons.remove(subunitNumber)
                    self?.showRegenerateSubUnits.remove(Int(subunitNumber))
                case .finished:
                    print("NotesViewModel: Finished generating lessons")
                }
            } receiveValue: { [weak self] lessons in
                for i in 0..<self!.curriculum.units.count {
                    for j in 0..<self!.curriculum.units[i].subUnits!.count {
                        if self!.curriculum.units[i].subUnits![j].unitNumber == subunitNumber {
                            self!.curriculum.units[i].subUnits![j].lessons = lessons.lessons
                            print("Lessons: \(lessons.lessons)")
                            self?.loadingIndexes_lessons.remove(subunitNumber)
                            break
                        }
                    }
                }
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
    
    func submitLessons(with index: Double) {
        UnitService_firestore.shared.pushSubUnits(units: curriculum.units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to push lessons")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished pushing lessons")
                }
            } receiveValue: { [weak self] _ in
                self?.submittedLessons.insert(index)
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
    
    func trashLessons(with unitIndex: Int, and subUnitIndex: Int) {
        self.loadingIndexes_lessons.insert(self.curriculum.units[unitIndex].subUnits![subUnitIndex].unitNumber)
        self.curriculum.units[unitIndex].subUnits![subUnitIndex].lessons = nil
        
        UnitService_firestore.shared.pushSubUnits(units: curriculum.units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to trash lessons")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished trashing lessons")
                }
            } receiveValue: { [weak self] _ in
//                if !regenerating {
                self?.loadingIndexes_lessons.remove(self!.curriculum.units[unitIndex].subUnits![subUnitIndex].unitNumber)
//                }
                self?.submittedLessons.remove(self!.curriculum.units[unitIndex].subUnits![subUnitIndex].unitNumber)
            }
            .store(in: &cancellables)
    }
    
    func generateNotes(for lessonNumber: String, unitNumber: Int) {
        
        var unit = self.curriculum.units[unitNumber - 1]
        
        //We do not need the notes in the prompt as it will increase cost and wont increase output
        if unit.subUnits != nil {
            for i in 0..<unit.subUnits!.count {
                if unit.subUnits![i].lessons != nil {
                    for j in 0..<unit.subUnits![i].lessons!.count {
                        unit.subUnits![i].lessons![j].notes = nil
                    }
                }
            }
        }
        
        CourseCreationService().generateNotes(input: NotesInput(lessonNumber: lessonNumber, unit: unit))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get notes")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished generating notes")
                }
            } receiveValue: { [weak self] notes in
                for i in 0..<self!.curriculum.units[unitNumber].subUnits!.count {
                    if self!.curriculum.units[unitNumber].subUnits![i].lessons != nil {
                        for j in 0..<self!.curriculum.units[unitNumber].subUnits![i].lessons!.count {
                            if self!.curriculum.units[unitNumber].subUnits![i].lessons![j].lessonNumber == lessonNumber {
                                self!.curriculum.units[unitNumber].subUnits![i].lessons![j].notes = notes
                                break
                            }
                        }
                    }
                }
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
                        
                        if let _ = self!.curriculum.units[i].subUnits {
                            for j in 0..<self!.curriculum.units[i].subUnits!.count {
                                if self!.curriculum.units[i].subUnits![j].lessons != nil {
                                    self?.submittedLessons.insert(self!.curriculum.units[i].subUnits![j].unitNumber)
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellables)
    }
}
