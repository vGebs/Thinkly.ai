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
    
    @Published var curriculums: [Curriculum] = [Curriculum(units: [])]
    
    @Published var errorOccurred = -1
    @Published var stopped: [Int] = []
    
    var cancellables: [AnyCancellable] = []
    
    let courseCreation: CourseCreationService
    let courseDef: CourseOverview?
    
    @Published var doneGenerating = [false, false, false]
    
    init(courseDef: CourseOverview?) {
        //on init we need to fetch the weekly content
        //we will not store all of weeks in the same document (faster fetching)
        //Once we get the CourseDefinition,
        self.courseDef = courseDef
        self.courseCreation = CourseCreationService()
    }
    
    @Published var loading = false
    
    func generateNewCurriculum(_ selectedVersion: Int) {
        if self.curriculums[0].units.count > 0 {
            self.curriculums.append(Curriculum(units: []))
        }
        
        self.getCurriculum(selectedVersion: selectedVersion)
    }
    
    func regenerateVersion(_ selectedVersion: Int) {
        self.resetUnits(selectedVersion)
        self.getCurriculum(selectedVersion: selectedVersion)
    }
    
    func continueGeneratingCurriculum(selectedVersion: Int) {
        stopped.removeAll { int in
            int == selectedVersion
        }
        errorOccurred = -1
        self.getCurriculum(selectedVersion: selectedVersion)
    }
    
    private func getCurriculum(selectedVersion: Int) {
        self.loading = true
        
        courseCreation.getCurriculum(prompt: "I want to learn about object oriented programming")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get curriculum")
                    print("NotesViewModel-err: \(e)")
                    self?.loading = false
                    self?.errorOccurred = selectedVersion
                case .finished:
                    print("NotesViewModel: Finished generating curriculum")
                }
            } receiveValue: { [weak self] curriculum in
                self?.loading = false
                self?.curriculums[selectedVersion].units = curriculum.units
                self?.doneGenerating[selectedVersion].toggle()
                
                self?.stopped.removeAll { int in
                    int == selectedVersion
                }
            }.store(in: &cancellables)

    }
    
    func stopGenerating(_ selectedVersion: Int) {
        self.cancellables = []
        self.stopped.append(selectedVersion)
        self.loading = false
    }
    
    func resetUnits(_ selectedVersion: Int) {
        self.curriculums[selectedVersion].units = []
        self.stopped.removeAll { int in
            int == selectedVersion
        }
        self.doneGenerating[selectedVersion] = false
    }
    
    func trashVersion(number: Int) {
        if curriculums.count > 1 {
            curriculums.remove(at: number)
        } else {
            curriculums[number].units = []
        }
    }
    
    private var submitCancellable: AnyCancellable?
    
    func submitUnits(_ selectedVersion: Int) {
//        self.submitCancellable = UnitService_firestore.shared.pushUnits(units: self.curriculums[selectedVersion].units, uid: AppState.shared.user!.uid, courseID: courseDef!.documentID!)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .failure(let e):
//                    print("NotesViewModel: Failed to push units")
//                    print("NotesViewModel-err: \(e)")
//                case .finished:
//                    print("NotesViewModel: Finished pushing units to firestore")
//                }
//            } receiveValue: { docID in }
    }
}
