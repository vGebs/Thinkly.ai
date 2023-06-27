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
    
    @Published var preliminaryCurriculum: [WeeklyTopicLocked] = [
        
    ]
    //WeeklyTopicLocked(weeklyTopic: WeeklyTopic(weekNumber: 1, topicDescription: "Description awe f awe fa wef a we fa we fa we f awe f awe f awe fa wef ", topicTitle: "Intro to shittin"))
    @Published var preliminaryCurriculumLocked = false
    
    @Published var preliminaryCurriculumWeekInput: PreliminaryCurriculumWeekInput
    
    var cancellables: [AnyCancellable] = []
    
    let courseCreation: CourseCreationService
    let courseDef: Course_selfLearn?
    
    init(courseDef: Course_selfLearn?) {
        //on init we need to fetch the weekly content
        //we will not store all of weeks in the same document (faster fetching)
        //Once we get the CourseDefinition,
        self.courseDef = courseDef
        self.courseCreation = CourseCreationService()
        
//        if let courseDef = courseDef {
//            self.preliminaryCurriculumWeekInput = PreliminaryCurriculumWeekInput(
//                weekNumber: 1, totalWeeks: courseDef.courseFull.courseTimingStructure.courseDurationInWeeks, course: PreliminaryCurriculumInput(gradeLevel: courseDef.courseFull.gradeLevel,
//                                                                  textBooks: courseDef.courseFull.textbooks,
//                                                                  learningObjectives: courseDef.courseFull.learningObjectives,
//                                                                  courseOverview: courseDef.courseFull.courseOverview,
//                                                                  prerequisites: courseDef.courseFull.prerequisites,
//                                                                  weeklyTopic: [])
//
//            )
//        } else {
            self.preliminaryCurriculumWeekInput = PreliminaryCurriculumWeekInput(weekNumber: 0, totalWeeks: 0, course: PreliminaryCurriculumInput(gradeLevel: "", textBooks: [], learningObjectives: [], courseOverview: CourseOverview(courseTitle: "", courseDescription: ""), prerequisites: [], weeklyTopic: []))
//        }
        
        self.observePreliminaryCurriculum()
    }
    
    @Published var loading = false
    
    func generatePreliminaryCurriculum() {
        
        self.loading = true
            
        generatePreliminaryCurriculum(withInput: self.preliminaryCurriculumWeekInput)
    }
    
    private func generatePreliminaryCurriculum(withInput: PreliminaryCurriculumWeekInput) {
        courseCreation.generatePreliminaryCurriculum(data: withInput)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to get weekly topic")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished getting weekly topic for week: \(withInput.weekNumber)")
                }
            } receiveValue: { [weak self] topic in
                let newTopic = WeeklyTopicLocked(weeklyTopic: topic)
                self?.preliminaryCurriculum.append(newTopic)
                self?.preliminaryCurriculumWeekInput.course.weeklyTopic.append(topic)
                self?.preliminaryCurriculumWeekInput.weekNumber += 1
                
//                if self!.courseDef!.courseFull.courseTimingStructure.courseDurationInWeeks >= self!.preliminaryCurriculumWeekInput.weekNumber {
//                    self?.generatePreliminaryCurriculum(withInput: self!.preliminaryCurriculumWeekInput)
//                }
                
//                if self!.courseDef!.courseFull.courseTimingStructure.courseDurationInWeeks == self!.preliminaryCurriculumWeekInput.weekNumber {
//                    self?.loading = false
//                }
            }.store(in: &cancellables)
    }
    
    func lockAllUnits() {
        for i in 0..<preliminaryCurriculum.count {
            preliminaryCurriculum[i].lockedin = true
        }
    }
    
    func regenerateUnlocked() {
        let weeksToFetch = preliminaryCurriculum.filter { !$0.lockedin }.map { $0.weeklyTopic.weekNumber }
        preliminaryCurriculum = preliminaryCurriculum.filter { $0.lockedin }
        
        let topics = preliminaryCurriculum.map { $0.weeklyTopic }
        
//        for week in weeksToFetch {
//            generateUnit(for: week, prelim: PreliminaryCurriculumWeekInput(weekNumber: week, totalWeeks: courseDef!.courseFull.courseTimingStructure.courseDurationInWeeks, course: PreliminaryCurriculumInput(gradeLevel: courseDef!.courseFull.gradeLevel, textBooks: courseDef!.courseFull.textbooks, learningObjectives: courseDef!.courseFull.learningObjectives,courseOverview: courseDef!.courseFull.courseOverview, prerequisites: courseDef!.courseFull.prerequisites, weeklyTopic: topics)))
//        }
    }
    
    func generateUnit(for weekNumber: Int, prelim: PreliminaryCurriculumWeekInput) {
        courseCreation.generatePreliminaryCurriculum(data: prelim)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("NotesViewModel: Failed to generate unit")
                    print("NotesViewModel-err: \(e)")
                case .finished:
                    print("NotesViewModel: Finished generating unit")
                }
            } receiveValue: { [weak self] topic in
                self?.preliminaryCurriculum.append(WeeklyTopicLocked(weeklyTopic: topic))
            }.store(in: &cancellables)
    }
    
    func allLocked() -> Bool {
        for topic in preliminaryCurriculum {
            if !topic.lockedin {
                return false
            }
        }
        return true
    }
    
    func unlockAll() {
        for i in 0..<preliminaryCurriculum.count {
            preliminaryCurriculum[i].lockedin = false
        }
    }
}

extension NotesViewModel {
    private func observePreliminaryCurriculum() {
        $preliminaryCurriculum
            .sink { [weak self] _ in
                self?.sortPreliminaryCurriculum()
            }
            .store(in: &cancellables)
    }
    
    private func sortPreliminaryCurriculum() {
        DispatchQueue.main.async {
            if self.preliminaryCurriculum.count > 1 {
                self.preliminaryCurriculum.sort { $0.weeklyTopic.weekNumber < $1.weeklyTopic.weekNumber }
            }
        }
    }
}
