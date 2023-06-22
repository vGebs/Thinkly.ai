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
    
    @Published var preliminaryCurriculum: [WeeklyTopic] = []
    @Published var preliminaryCurriculumLocked = false
    
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
    }
    
    @Published var loading = false
    
    func generatePreliminaryCurriculum() {
        if let courseDef = courseDef {
            let prelim = PreliminaryCurriculumInput(
                courseTimingStructure: courseDef.courseFull.courseTimingStructure,
                gradeLevel: courseDef.courseFull.gradeLevel,
                textBooks: courseDef.courseFull.textbooks,
                learningObjectives: courseDef.courseFull.learningObjectives,
                courseOverview: courseDef.courseFull.courseOverview,
                prerequisites: courseDef.courseFull.prerequisites
            )
            
            self.loading = true
            
            courseCreation.generatePreliminaryCurriculum(data: prelim)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("NotesViewModel: Failed to get preliminary curriculum.")
                        print("NotesViewModel-err: \(e)")
                        self?.loading = false
                    case .finished:
                        print("NotesViewModel: Finished generatePreliminaryCurriculum")
                    }
                } receiveValue: { [weak self] prelimOutput in
                    self?.loading = false
                    self?.preliminaryCurriculum = prelimOutput.curriculum
                    
                }.store(in: &cancellables)
        }
    }
}
