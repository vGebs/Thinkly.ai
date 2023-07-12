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
    
//    @Published var preliminaryCurriculum: [WeeklyTopic] = []
    //WeeklyTopicLocked(weeklyTopic: WeeklyTopic(weekNumber: 1, topicDescription: "Description awe f awe fa wef a we fa we fa we f awe f awe f awe fa wef ", topicTitle: "Intro to shittin"))
    @Published var preliminaryCurriculumLocked = false
    
    @Published var preliminaryCurriculumWeekInput: [PreliminaryCurriculumWeekInput] = []
    
    var cancellables: [AnyCancellable] = []
    
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
                weekNumber: 1,
                totalWeeks: 15,
                course: PreliminaryCurriculumInput(textBooks: courseDef.courseFull.textbooks, learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, weeklyTopic: [])
            ))
        } else {
            self.preliminaryCurriculumWeekInput.append(PreliminaryCurriculumWeekInput(weekNumber: 0, totalWeeks: 0, course: PreliminaryCurriculumInput(textBooks: [], learningObjectives: [], courseOverview: CourseOverview(courseTitle: "", courseDescription: ""), weeklyTopic: [])))
        }
        
//        self.observePreliminaryCurriculum()
    }
    
    @Published var loading = false
    
    func generatePreliminaryCurriculum(selectedVersion: Int) {
        
        self.loading = true
        
        if selectedVersion >= self.preliminaryCurriculumWeekInput.count {
            if let courseDef = courseDef {
                self.preliminaryCurriculumWeekInput.append(PreliminaryCurriculumWeekInput(
                    weekNumber: 1,
                    totalWeeks: 15,
                    course: PreliminaryCurriculumInput(textBooks: courseDef.courseFull.textbooks, learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, weeklyTopic: [])
                ))
            }
        } else {
            self.preliminaryCurriculumWeekInput[selectedVersion].course.weeklyTopic = []
            self.preliminaryCurriculumWeekInput[selectedVersion].weekNumber = 1
        }
        
        if selectedVersion <= self.preliminaryCurriculumWeekInput.count {
            generatePreliminaryCurriculum(selectedVersion: selectedVersion, withInput: self.preliminaryCurriculumWeekInput[selectedVersion])
        }
    }
    
    private func generatePreliminaryCurriculum(selectedVersion: Int, withInput: PreliminaryCurriculumWeekInput) {
        courseCreation.generatePreliminaryCurriculum(data: withInput)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get weekly topic")
                    print("NotesViewModel-err: \(e)")
                    self?.loading = false
                case .finished:
                    print("NotesViewModel: Finished getting weekly topic for week: \(withInput.weekNumber)")
                }
            } receiveValue: { [weak self] topic in
                self?.preliminaryCurriculumWeekInput[selectedVersion].course.weeklyTopic.append(topic)
                self?.preliminaryCurriculumWeekInput[selectedVersion].weekNumber += 1

                if self!.preliminaryCurriculumWeekInput[selectedVersion].weekNumber <= 15 {
                    self?.generatePreliminaryCurriculum(selectedVersion: selectedVersion, withInput: self!.preliminaryCurriculumWeekInput[selectedVersion])
                }

                if self!.preliminaryCurriculumWeekInput[selectedVersion].weekNumber == 15 {
                    self?.loading = false
                }
            }.store(in: &cancellables)

    }
    
    func trashVersion(number: Int) {
        if self.preliminaryCurriculumWeekInput.count == 1 {
            if let courseDef = courseDef {
                self.preliminaryCurriculumWeekInput.remove(at: number)
                
                self.preliminaryCurriculumWeekInput = [(PreliminaryCurriculumWeekInput(
                    weekNumber: 1,
                    totalWeeks: 15,
                    course: PreliminaryCurriculumInput(textBooks: courseDef.courseFull.textbooks, learningObjectives: courseDef.courseFull.learningObjectives, courseOverview: courseDef.courseFull.courseOverview, weeklyTopic: [])
                ))]
            }
        } else if self.preliminaryCurriculumWeekInput.count > 1 {
            self.preliminaryCurriculumWeekInput.remove(at: number)
        }
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
