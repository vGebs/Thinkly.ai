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
        
        //remove all other lessons for input, they are not needed for the prompt.
        for i in 0..<c.units.count {
            
            //we need to remove all other subunits when fetching
            c.units[i].subUnits = nil
        }
        
        CourseCreationService().getSubUnits(GetSubUnits(uid: AuthService.shared.user!.uid, unitNumber: index + 1, curriculum: c.units))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get subunits")
                    print("NotesViewModel-err: \(e)")
                    self?.loadingIndexes.remove(index)
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
        withAnimation {
            loadingIndexes_lessons.insert(subunitNumber)
        }
        //subUnitsThatHaveLessons.insert(Int(subunitNumber))
        
        for i in 0..<self.curriculum.units.count {
            if self.curriculum.units[i].subUnits != nil {
                for j in 0..<self.curriculum.units[i].subUnits!.count {
                    if self.curriculum.units[i].subUnits![j].unitNumber == subunitNumber {
                        if self.curriculum.units[i].subUnits![j].lessons != nil {
                            withAnimation {
                                self.curriculum.units[i].subUnits![j].lessons = nil
                                self.trashLessons(with: i, and: self.curriculum.units[i].subUnits![j].unitNumber)
                            }
                        }
                        break
                    }
                }
            }
        }
        
        var inputUnits = self.curriculum.units
        
        //remove all other lessons for input, they are not needed for the prompt.
        for i in 0..<inputUnits.count {
            if inputUnits[i].subUnits != nil {
                for j in 0..<inputUnits[i].subUnits!.count {
                    inputUnits[i].subUnits![j].lessons = nil
                }
            }
        }
        
        CourseCreationService().generateLessonsForSubunit(GetLessons(uid: AuthService.shared.user!.uid, curriculum: inputUnits, subunitNumber: subunitNumber))
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
                
                var failed = false
                
                //Check to see if the lessonNumber contains the subunits number
                for lesson in lessons.lessons {
                    if lesson.lessonNumber.prefix(String(subunitNumber).count) != String(subunitNumber) {
                        failed = true
                        break
                    }
                }
                
                if !failed {
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
                } else {
                    self?.loadingIndexes_lessons.remove(subunitNumber)
                }
            }.store(in: &cancellables)
    }
    
    func submitUnits(with index: Int) {
        //remove all other units and all lessons+notes
        var units = curriculum.units
        
        for i in 0..<units.count {
            //make sure we dont push sub units that are not submitted
            if !submittedSubUnits.contains(units[i].unitNumber - 1) {
                if i != index {
                    units[i].subUnits = nil
                }
                
                if let _ = units[i].subUnits {
                    for j in 0..<units[i].subUnits!.count {
                        
                        if !submittedLessons.contains(units[i].subUnits![j].unitNumber) {
                            units[i].subUnits![j].lessons = nil
                        }
                    }
                }
            } else if submittedSubUnits.contains(units[i].unitNumber - 1) {
                
                if let _ = units[i].subUnits {
                    for j in 0..<units[i].subUnits!.count {
                        
                        if !submittedLessons.contains(units[i].subUnits![j].unitNumber) {
                            units[i].subUnits![j].lessons = nil
                        } else {
                            if let _ = units[i].subUnits![j].lessons {
                                for k in 0..<units[i].subUnits![j].lessons!.count {
                                    units[i].subUnits![j].lessons![k].notes = nil
                                }
                            }
                        }
                    }
                }
            }
        }
        
        UnitService_firestore.shared.pushSubUnits(units: units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
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
        
        var units = curriculum.units
        
        for i in 0..<units.count {
            //make sure we dont push sub units that are not submitted
            if !submittedSubUnits.contains(units[i].unitNumber - 1) {
                
                if let _ = units[i].subUnits {
                    for j in 0..<units[i].subUnits!.count {
                        
                        if !submittedLessons.contains(units[i].subUnits![j].unitNumber) {
                            if index != units[i].subUnits![j].unitNumber {
                                units[i].subUnits![j].lessons = nil
                                units[i].subUnits![j].assignment = nil
                            }
                        }
                    }
                }
            } else if submittedSubUnits.contains(units[i].unitNumber - 1) {
                
                if let _ = units[i].subUnits {
                    for j in 0..<units[i].subUnits!.count {
                        
                        if !submittedLessons.contains(units[i].subUnits![j].unitNumber) {
                            if index != units[i].subUnits![j].unitNumber {
                                units[i].subUnits![j].lessons = nil
                                units[i].subUnits![j].assignment = nil
                            }
                        } else {
                            if let _ = units[i].subUnits![j].lessons {
                                for k in 0..<units[i].subUnits![j].lessons!.count {
                                    units[i].subUnits![j].lessons![k].notes = nil
                                    units[i].subUnits![j].assignment = nil
                                }
                            }
                        }
                    }
                }
            }
        }
        
        UnitService_firestore.shared.pushSubUnits(units: units, courseID: curriculum.courseID!, docID: curriculum.documentID!)
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
                self?.submittedSubUnits.insert(Int(index))
                self?.submittedLessons.insert(index)
            }
            .store(in: &cancellables)
    }
    
    func trashSubUnits(with index: Int, regenerating: Bool = false) {
        self.loadingIndexes.insert(index)
        self.curriculum.units[index].subUnits = nil
        
        UnitService_firestore.shared.pushSubUnits(units: remove_notes_assignments_unSubmittedItems(), courseID: curriculum.courseID!, docID: curriculum.documentID!)
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
    
    func trashLessons(with unitIndex: Int, and subUnitNumber: Double) {
        let subUnitIndex = (Int(subUnitNumber * 10) % 10) - 1
        self.loadingIndexes_lessons.insert(subUnitNumber)
        self.curriculum.units[unitIndex].subUnits![subUnitIndex].lessons = nil
        
        UnitService_firestore.shared.pushSubUnits(units: remove_notes_assignments_unSubmittedItems(), courseID: curriculum.courseID!, docID: curriculum.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to trash lessons")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished trashing lessons for subunitNumber: \(subUnitNumber)")
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
                        //If there is existing notes where we are generating, we need to clear them/delete them from db
                        if unit.subUnits![i].lessons![j].lessonNumber == lessonNumber {
                            if unit.subUnits![i].lessons![j].notes != nil {
                                if submittedNotes.contains(lessonNumber) {
                                    self.deleteNotes(unitIndex: unitIndex, subunitNumber: self.curriculum.units[unitIndex].subUnits![i].unitNumber, lessonNumber: lessonNumber)
                                } else {
                                    self.curriculum.units[unitIndex].subUnits![i].lessons![j].notes = nil
                                }
                            }
                        }
                        unit.subUnits![i].lessons![j].notes = nil
                    }
                }
            }
        }
        
        withAnimation {
            self.loadingNotesNumbers.insert(lessonNumber)
        }
        
        CourseCreationService().generateNotes(input: NotesInput(uid: AuthService.shared.user!.uid, lessonNumber: lessonNumber, unit: unit))
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
                            if curriculum.units[unitIndex].subUnits![i].lessons![j].lessonNumber == lessonNumber {
                                notes = curriculum.units[unitIndex].subUnits![i].lessons![j].notes!
                                break
                            }
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
    
    func hasNotes(for subunit: SubUnit) -> Bool {
        if let lessons = subunit.lessons {
            for lesson in lessons {
                if lesson.notes != nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    @Published var generatingAssignments: Set<Double> = []
    
    func generateAssignment(unitIndex: Int, subunitIndex: Int) {
        if let subunits = self.curriculum.units[unitIndex].subUnits {
            
            var subunit = subunits[subunitIndex]
            for i in 0..<subunit.lessons!.count {
                subunit.lessons![i].notes = nil
            }
            
            generatingAssignments.insert(subunit.unitNumber)
            
            AssignmentCreationService().generateAssignment(subunit: GenerateAssignment_Input(subunit: subunit, uid: AuthService.shared.user!.uid))
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("NotesViewModel: Failed to generate assignment")
                        print("NotesViewModel-err: \(e)")
                        self!.generatingAssignments.remove(subunit.unitNumber)
                    case .finished:
                        print("NotesViewModel: Finished generating assignment")
                    }
                } receiveValue: { [weak self] assignment in
                    self!.curriculum.units[unitIndex].subUnits![subunitIndex].assignment = assignment
                    self!.generatingAssignments.remove(subunit.unitNumber)
                }.store(in: &cancellables)
        }
    }
    
    @Published var submittedAssignments: Set<Double> = []
    
    func submitAssignment(unitIndex: Int, subunitIndex: Int) {
        
        if let subunits = self.curriculum.units[unitIndex].subUnits {
            
            let subunit = subunits[subunitIndex]
            let assignment = Assignment_Firestore(assignment: subunit.assignment!, courseID: self.curriculum.courseID!, subunitNumber: subunit.unitNumber)
            AssignmentService_Firestore.shared.pushAssignment(assignment: assignment)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("NotesViewModel: Failed pushing assignment")
                        print("NotesViewModel-err: \(e)")
                    case .finished:
                        print("NotesViewModel: Finished pushing assignment")
                        self!.submittedAssignments.insert(subunit.unitNumber)
                    }
                } receiveValue: { docID in
                    self.curriculum.units[unitIndex].subUnits![subunitIndex].assignment!.docID = docID
                }
                .store(in: &cancellables)
        }
    }
    
    func deleteAssignment(unitIndex: Int, subunitIndex: Int) {
        if let subunits = self.curriculum.units[unitIndex].subUnits {
            
            let subunit = subunits[subunitIndex]
            
            if let assignment = subunit.assignment {
                if let docID = assignment.docID {
                    AssignmentService_Firestore.shared.deleteAssignment(docID: docID)
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] completion in
                            switch completion {
                            case .failure(let e):
                                print("NotesViewModel: Failed deleting assignment")
                                print("NotesViewModel-err: \(e)")
                            case .finished:
                                print("NotesViewModel: Finished deleting assignment")
                                self!.curriculum.units[unitIndex].subUnits![subunitIndex].assignment = nil
                            }
                        } receiveValue: { _ in }
                        .store(in: &cancellables)
                } else {
                    self.curriculum.units[unitIndex].subUnits![subunitIndex].assignment = nil
                }
            }
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
                                    self?.fetchAssignments(unitIndex: i, subunitIndex: j, subunitNumber: self!.curriculum.units[i].subUnits![j].unitNumber)
                                    
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
    
    private func fetchAssignments(unitIndex: Int, subunitIndex: Int, subunitNumber: Double) {
        AssignmentService_Firestore.shared.fetchAssignment(courseID: self.curriculum.courseID!, subunitNumber: subunitNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to fetch assignment with subunitNumber: \(subunitNumber)")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished fetching assignment for subunit: \(subunitNumber) ")
                }
            } receiveValue: { [weak self] assignments in
                if assignments.count > 0 {
                    self!.curriculum.units[unitIndex].subUnits![subunitIndex].assignment = assignments[0].assignment
                    self!.submittedAssignments.insert(subunitNumber)
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
                                            self!.curriculum.units[i].subUnits![j].lessons![k].notes?.docID = notesArr[0].documentID
                                            self!.submittedNotes.insert(self!.curriculum.units[i].subUnits![j].lessons![k].lessonNumber)
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
    
    func deleteNotes(unitIndex: Int, subunitNumber: Double, lessonNumber: String) {
        
        let subunitIndex = Int((subunitNumber * 10).truncatingRemainder(dividingBy: 10)) - 1
        
        let lastCharacter = lessonNumber.last!
        let lastNumber = Int(String(lastCharacter))!
        let lessonIndex = lastNumber - 1
        
        deleteNotes(unitIndex: unitIndex, subunitIndex: subunitIndex, lessonIndex: lessonIndex, lessonNumber: lessonNumber)
    }
    
    private func deleteNotes(unitIndex: Int, subunitIndex: Int, lessonIndex: Int, lessonNumber: String) {
        
        if let subUnits = self.curriculum.units[unitIndex].subUnits {
            if let lessons = subUnits[subunitIndex].lessons {
                if let notes = lessons[lessonIndex].notes {
                    if let docID = notes.docID {
                        NotesService_Firestore.shared.deleteNotes(with: docID)
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] completion in
                                switch completion {
                                case .failure(let e):
                                    print("NotesViewModel: Failed to delete notes")
                                    print("NotesViewModel-err: \(e)")
                                case .finished:
                                    print("NotesViewModel: Finished deleting notes")
                                    self!.submittedNotes.remove(lessonNumber)
                                    self!.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![lessonIndex].notes = nil
                                }
                            } receiveValue: { _ in }
                            .store(in: &cancellables)

                    }
                }
            }
        }
    }
    
    private func remove_notes_assignments_unSubmittedItems() -> [Unit] {
        var units = curriculum.units
        
        for i in 0..<units.count {
            if !submittedSubUnits.contains(i) {
                units[i].subUnits = nil
            } else {
                if units[i].subUnits != nil {
                    for j in 0..<units[i].subUnits!.count {
                        if !submittedLessons.contains(units[i].subUnits![j].unitNumber) {
                            units[i].subUnits![j].lessons = nil
                        } else {
                            units[i].subUnits![j].assignment = nil
                            
                            if units[i].subUnits![j].lessons != nil {
                                for k in 0..<units[i].subUnits![j].lessons!.count {
                                    units[i].subUnits![j].lessons![k].notes = nil
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return units
    }
}
