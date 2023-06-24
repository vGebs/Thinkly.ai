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
    
    @Published var weeklyContent: [WeeklyContent] = [
        
    ]
    
    @Published var preliminaryCurriculum: [WeeklyTopicLocked] = [
        WeeklyTopicLocked(weeklyTopic: WeeklyTopic(weekNumber: 1, topicDescription: "Description awe f awe fa wef a we fa we fa we f awe f awe f awe fa wef ", topicTitle: "Intro to the best shittin course around folks"))
    ]
    //WeeklyTopicLocked(weeklyTopic: WeeklyTopic(weekNumber: 1, topicDescription: "Description awe f awe fa wef a we fa we fa we f awe f awe f awe fa wef ", topicTitle: "Intro to shittin"))
    @Published var preliminaryCurriculumLocked = false
    
    @Published var preliminaryCurriculumWeekInput: PreliminaryCurriculumWeekInput
    
    var cancellables: [AnyCancellable] = []
    
    let courseCreation: CourseCreationService
    let courseDef: CourseDefinition?
    
//    WeeklyContent(
//        notesOutline: [],
//        assessments: [],
//        topics: [
//            Topic(readings: [
//                Reading(
//                    chapter: 1,
//                    textbook: Textbook(
//                        title: "Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems",
//                        author: "Martin Kleppmann"
//                )),
//                Reading(
//                    chapter: 1,
//                    textbook: Textbook(
//                        title: "FUNDAMENTALS OF SOFTWARE ARCHITECTURE: AN ENGINEERING APPROACH",
//                        author: "Mark Richards"
//                    )),
//                Reading(
//                    chapter: 1,
//                    textbook: Textbook(
//                        title: "Clean Architecture: A Craftsman's Guide to Software Structure and Design",
//                        author: "Robert Martin"
//                    ))
//                 ],
//                  topicName: "Introduction to Software Architecture"),
//
//            Topic(readings: [
//                Reading(
//                    chapter: 2,
//                    textbook: Textbook(
//                        title: "FUNDAMENTALS OF SOFTWARE ARCHITECTURE: AN ENGINEERING APPROACH",
//                        author: "Mark Richards"
//                    ))
//            ],
//                  topicName: "Software Requirements and Design")
//        ],
//        week: 1,
//        classOutline: []
//    )
    
    init(courseDef: CourseDefinition?) {
        //on init we need to fetch the weekly content
        //we will not store all of weeks in the same document (faster fetching)
        //Once we get the CourseDefinition,
        self.courseDef = courseDef
        self.courseCreation = CourseCreationService()
        
        if let courseDef = courseDef {
            self.preliminaryCurriculumWeekInput = PreliminaryCurriculumWeekInput(
                weekNumber: 1, totalWeeks: courseDef.courseFull.courseTimingStructure.courseDurationInWeeks, course: PreliminaryCurriculumInput(gradeLevel: courseDef.courseFull.gradeLevel,
                                                                  textBooks: courseDef.courseFull.textbooks,
                                                                  learningObjectives: courseDef.courseFull.learningObjectives,
                                                                  courseOverview: courseDef.courseFull.courseOverview,
                                                                  prerequisites: courseDef.courseFull.prerequisites,
                                                                  weeklyTopic: [])
                
            )
        } else {
            self.preliminaryCurriculumWeekInput = PreliminaryCurriculumWeekInput(weekNumber: 0, totalWeeks: 0, course: PreliminaryCurriculumInput(gradeLevel: "", textBooks: [], learningObjectives: [], courseOverview: CourseOverview(courseTitle: "", courseDescription: ""), prerequisites: [], weeklyTopic: []))
        }
    }
    
    @Published var loading = false
    
    func generatePreliminaryCurriculum() {
        if let courseDef = courseDef {
            self.loading = true
            
            generatePreliminaryCurriculum(withInput: self.preliminaryCurriculumWeekInput)
        }
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
                
                if self!.courseDef!.courseFull.courseTimingStructure.courseDurationInWeeks >= self!.preliminaryCurriculumWeekInput.weekNumber {
                    self?.generatePreliminaryCurriculum(withInput: self!.preliminaryCurriculumWeekInput)
                }
                
                if self!.courseDef!.courseFull.courseTimingStructure.courseDurationInWeeks == self!.preliminaryCurriculumWeekInput.weekNumber {
                    self?.loading = false
                }
            }.store(in: &cancellables)

    }
}
