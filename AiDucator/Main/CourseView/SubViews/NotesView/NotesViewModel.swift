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
    
//    @Published var subUnitsThatHaveLessons: Set<Double> = []
    @Published var loadingNotesNumbers: Set<String> = []
    
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
        //subUnitsThatHaveLessons.insert(Int(subunitNumber))
        
        for i in 0..<self.curriculum.units.count {
            if self.curriculum.units[i].subUnits != nil {
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
        }
        
        CourseCreationService().generateLessonsForSubunit(GetLessons(curriculum: self.curriculum.units, subunitNumber: subunitNumber))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: failed to generate lessons")
                    print("NotesViewModel-err: \(e)")
                    self?.loadingIndexes_lessons.remove(subunitNumber)
//                    self?.subUnitsThatHaveLessons.remove(Int(subunitNumber))
                case .finished:
                    print("NotesViewModel: Finished generating lessons")
                }
            } receiveValue: { [weak self] lessons in
                if lessons.lessons.count != 0 {
                    for i in 0..<self!.curriculum.units.count {
                        if self!.curriculum.units[i].subUnits != nil {
                            for j in 0..<self!.curriculum.units[i].subUnits!.count {
                                if self!.curriculum.units[i].subUnits![j].unitNumber == subunitNumber {
                                    self!.curriculum.units[i].subUnits![j].lessons = lessons.lessons
                                    print("Lessons: \(lessons.lessons)")
                                    self?.loadingIndexes_lessons.remove(subunitNumber)
                                    break
                                }
                            }
                        }
                    }
                } else {
                    self?.loadingIndexes_lessons.remove(subunitNumber)
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
    
    func generateNotes(for lessonNumber: String, unitIndex: Int) {
        
        var unit = self.curriculum.units[unitIndex]
        
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
        
        withAnimation {
            self.loadingNotesNumbers.insert(lessonNumber)
        }
        
        CourseCreationService().generateNotes(input: NotesInput(lessonNumber: lessonNumber, unit: unit))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get notes")
                    print("NotesViewModel-err: \(e)")
                    withAnimation {
                        self!.loadingNotesNumbers.remove(lessonNumber)
                    }
                case .finished:
                    print("NotesViewModel: Finished generating notes")
                }
            } receiveValue: { [weak self] notes in
                for i in 0..<self!.curriculum.units[unitIndex].subUnits!.count {
                    if self!.curriculum.units[unitIndex].subUnits![i].lessons != nil {
                        for j in 0..<self!.curriculum.units[unitIndex].subUnits![i].lessons!.count {
                            if self!.curriculum.units[unitIndex].subUnits![i].lessons![j].lessonNumber == lessonNumber {
                                self!.curriculum.units[unitIndex].subUnits![i].lessons![j].notes = notes
                                self!.loadingNotesNumbers.remove(lessonNumber)
                                break
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func lessonHasNotes(unitIndex: Int, subunitNumber: Double, lessonNumber: String) -> Bool { //
        if self.curriculum.units[unitIndex].subUnits != nil {
            for i in 0..<curriculum.units[unitIndex].subUnits!.count {
                if curriculum.units[unitIndex].subUnits![i].lessons != nil && curriculum.units[unitIndex].subUnits![i].unitNumber == subunitNumber{
                    for j in 0..<curriculum.units[unitIndex].subUnits![i].lessons!.count {
                        if curriculum.units[unitIndex].subUnits![i].lessons![j].notes != nil && curriculum.units[unitIndex].subUnits![i].lessons![j].lessonNumber == lessonNumber {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func subunitHasNotes(unitIndex: Int, subunitNumber: Double) -> Bool {
        if self.curriculum.units[unitIndex].subUnits != nil {
            for i in 0..<curriculum.units[unitIndex].subUnits!.count {
                if curriculum.units[unitIndex].subUnits![i].lessons != nil && curriculum.units[unitIndex].subUnits![i].unitNumber == subunitNumber{
                    for j in 0..<curriculum.units[unitIndex].subUnits![i].lessons!.count {
                        if curriculum.units[unitIndex].subUnits![i].lessons![j].notes != nil {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    @Published var submittedNotes: Set<String> = []
    func submitNotes(unitIndex: Int, subunitNumber: Double, lessonNumber: String) {
        //courseID
        //lesson number
        //notes: [Paragraph]
        var notes: Notes?
        
        if self.curriculum.units[unitIndex].subUnits != nil {
            for i in 0..<curriculum.units[unitIndex].subUnits!.count {
                if curriculum.units[unitIndex].subUnits![i].lessons != nil && curriculum.units[unitIndex].subUnits![i].unitNumber == subunitNumber{
                    for j in 0..<curriculum.units[unitIndex].subUnits![i].lessons!.count {
                        if curriculum.units[unitIndex].subUnits![i].lessons![j].notes != nil {
                            notes = curriculum.units[unitIndex].subUnits![i].lessons![j].notes!
                        }
                    }
                }
            }
        }
        
    
        if let n = notes {
            NotesService_Firestore.shared.addNotes(Notes_Firestore(notes: n, lessonNumber: lessonNumber, courseID: curriculum.courseID!))
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("NotesViewModel: Failed to push notes for lesson: \(lessonNumber)")
                        print("NotesViewModel-err: \(e)")
                    case .finished:
                        print("NotesViewModel: Finished pushing notes for lesson: \(lessonNumber)")
                        withAnimation {
                            self!.submittedNotes.insert(lessonNumber)
                        }
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)

        } else {
            print("NotesViewModel: There is no notes to submit for this lesson: \(lessonNumber)")
        }
    }
}

extension NotesViewModel {
    private func fetchCurriculum(courseID: String) {
        var fetchedLessonNumbers = Set<String>() // keep track of the lesson numbers fetched
        
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
                                    
                                    for k in 0..<self!.curriculum.units[i].subUnits![j].lessons!.count {
                                        let lessonNumber = self!.curriculum.units[i].subUnits![j].lessons![k].lessonNumber
                                        
                                        if !fetchedLessonNumbers.contains(lessonNumber) {
                                            self!.fetchNotes(courseID: self!.curriculum.courseID!, lessonNumber: lessonNumber)
                                            fetchedLessonNumbers.insert(lessonNumber)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellables)
    }
    
    private func fetchNotes(courseID: String, lessonNumber: String) {
        NotesService_Firestore.shared.getNotes(for: courseID, lessonNumber: lessonNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get notes with lessonNumber: \(lessonNumber)")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished fetching notes with lessonNumber: \(lessonNumber)")
                }
            } receiveValue: { [weak self] notesArr in
                if notesArr.count > 0 {
                    for i in 0..<self!.curriculum.units.count {
                        if let _ = self!.curriculum.units[i].subUnits {
                            for j in 0..<self!.curriculum.units[i].subUnits!.count {
                                if let _ = self!.curriculum.units[i].subUnits![j].lessons {
                                    for k in 0..<self!.curriculum.units[i].subUnits![j].lessons!.count {
                                        if self!.curriculum.units[i].subUnits![j].lessons![k].lessonNumber == lessonNumber {
                                            self!.curriculum.units[i].subUnits![j].lessons![k].notes = notesArr[0].notes
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellables)

    }
}
