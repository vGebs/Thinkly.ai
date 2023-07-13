//
//  NotesViewModel.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-18.
//

import Foundation
import Combine

//for this class we need to fetch all of the notes for that class.
//So for the course they are in, fetch all of the notes,

class NotesViewModel: ObservableObject {
    
    @Published var preliminaryCurriculumWeekInput: [PreliminaryCurriculumWeekInput] = []
    
    @Published var errorOccurred = -1
    @Published var stopped: [Int] = []
    
    var cancellables: [Int: [AnyCancellable]] = [:]
    
    let courseCreation: CourseCreationService
    let courseDef: CourseDefinition?
    
    init(courseDef: CourseDefinition?) {
        //on init we need to fetch the weekly content
        //we will not store all of weeks in the same document (faster fetching)
        //Once we get the CourseDefinition,
        self.courseDef = courseDef
        self.courseCreation = CourseCreationService()
        
        if let courseDef = courseDef {
            self.preliminaryCurriculumWeekInput.append(PreliminaryCurriculumWeekInput(
                unitNumber: 1,
                totalUnits: 15,
                course: PreliminaryCurriculumInput(learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, units: [])
            ))
        } else {
            self.preliminaryCurriculumWeekInput.append(PreliminaryCurriculumWeekInput(unitNumber: 0, totalUnits: 0, course: PreliminaryCurriculumInput(learningObjectives: [], courseOverview: CourseOverview(courseTitle: "", courseDescription: ""), units: [])))
        }
        
//        self.observePreliminaryCurriculum()
    }
    
    @Published var loading = false
    
    func generatePreliminaryCurriculum(selectedVersion: Int) {
        
        self.loading = true
        
        if selectedVersion >= self.preliminaryCurriculumWeekInput.count {
            if let courseDef = courseDef {
                self.preliminaryCurriculumWeekInput.append(PreliminaryCurriculumWeekInput(
                    unitNumber: 1,
                    totalUnits: 15,
                    course: PreliminaryCurriculumInput(textBooks: courseDef.courseFull.textbooks, learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, units: [])
                ))
            }
        } else {
            self.preliminaryCurriculumWeekInput[selectedVersion].course.units = []
            self.preliminaryCurriculumWeekInput[selectedVersion].unitNumber = 1
        }
        
        if selectedVersion <= self.preliminaryCurriculumWeekInput.count {
            generatePreliminaryCurriculum(selectedVersion: selectedVersion, withInput: self.preliminaryCurriculumWeekInput[selectedVersion])
        }
    }
    
    func continueGeneratingPreliminaryCurriculum(selectedVersion: Int) {
        stopped.removeAll { int in
            int == selectedVersion
        }
        errorOccurred = -1
        self.generatePreliminaryCurriculum(selectedVersion: selectedVersion, withInput: self.preliminaryCurriculumWeekInput[selectedVersion])
    }
    
    private func generatePreliminaryCurriculum(selectedVersion: Int, withInput: PreliminaryCurriculumWeekInput) {
        let cancellable = courseCreation.generatePreliminaryCurriculum(data: withInput)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get weekly topic")
                    print("NotesViewModel-err: \(e)")
                    self?.loading = false
                    self?.errorOccurred = selectedVersion
                case .finished:
                    print("NotesViewModel: Finished getting weekly topic for week: \(withInput.unitNumber)")
                }
            } receiveValue: { [weak self] topic in
                self?.preliminaryCurriculumWeekInput[selectedVersion].course.units.append(topic)
                self?.preliminaryCurriculumWeekInput[selectedVersion].unitNumber += 1

                if self!.preliminaryCurriculumWeekInput[selectedVersion].unitNumber <= 15 {
                    self?.generatePreliminaryCurriculum(selectedVersion: selectedVersion, withInput: self!.preliminaryCurriculumWeekInput[selectedVersion])
                }

                if self!.preliminaryCurriculumWeekInput[selectedVersion].unitNumber == 15 {
                    self?.loading = false
                }
            }
        
        if cancellables[selectedVersion] == nil {
            cancellables[selectedVersion] = [cancellable]
        } else {
            cancellables[selectedVersion]?.append(cancellable)
        }
    }
    
    func stopGenerating(_ selectedVersion: Int) {
        self.cancellables[selectedVersion] = []
        self.stopped.append(selectedVersion)
        self.loading = false
    }
    
    func resetUnits(_ selectedVersion: Int) {
        self.preliminaryCurriculumWeekInput[selectedVersion].course.units = []
        self.stopped.removeAll { int in
            int == selectedVersion
        }
    }
    
    func trashVersion(number: Int) {
        if self.preliminaryCurriculumWeekInput.count == 1 {
            if let courseDef = courseDef {
                self.preliminaryCurriculumWeekInput.remove(at: number)
                
                self.preliminaryCurriculumWeekInput = [(PreliminaryCurriculumWeekInput(
                    unitNumber: 1,
                    totalUnits: 15,
                    course: PreliminaryCurriculumInput(textBooks: courseDef.courseFull.textbooks, learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, units: [])
                ))]
            }
        } else if self.preliminaryCurriculumWeekInput.count > 1 {
            self.preliminaryCurriculumWeekInput.remove(at: number)
        }
    }
    
    private var submitCancellable: AnyCancellable?
    
    func submitUnits(_ selectedVersion: Int) {
        self.submitCancellable = UnitService_firestore.shared.pushUnits(units: self.preliminaryCurriculumWeekInput[selectedVersion].course.units, uid: AppState.shared.user!.uid, courseID: courseDef!.documentID!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to push units")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished pushing units to firestore")
                }
            } receiveValue: { docID in }
    }
}

//extension NotesViewModel {
//    private func observePreliminaryCurriculum() {
//        $preliminaryCurriculum
//            .sink { [weak self] _ in
//                self?.sortPreliminaryCurriculum()
//            }
//            .store(in: &cancellables)
//    }
//
//    private func sortPreliminaryCurriculum() {
//        DispatchQueue.main.async {
//            if self.preliminaryCurriculum.count > 1 {
//                self.preliminaryCurriculum.sort { $0.weekNumber < $1.weekNumber }
//            }
//        }
//    }
//}
