//
//  AddCoursePopUpViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import Combine
import SwiftUI
import Foundation

class AddCoursePopUpViewModel: ObservableObject {
    @Published var durationFrom = Date()
    @Published var durationTo = Date()
    @Published var selectedClassType = ClassType(id: "Computer Science", sfSymbol: "desktopcomputer")
    
    @Published var gradeLevelValid = false
    @Published var endDateValid = false
    
    private let courseDef = CourseDefinitionService()
    
    private var cancellables: [AnyCancellable] = []
    
    @Published var userPrompt = "" //I want to learn about software systems, especially to do with high volume applications and system design
    
    @Published var textbooks: [Textbook] = [
        
    ]
    
//    Textbook(
//        title: "Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems",
//        author: "Martin Kleppmann"
//    ),
//    Textbook(
//        title: "FUNDAMENTALS OF SOFTWARE ARCHITECTURE: AN ENGINEERING APPROACH",
//        author: "Mark Richards"
//    ),
//    Textbook(
//        title: "Clean Architecture: A Craftsman's Guide to Software Structure and Design",
//        author: "Robert Martin"
//    )
    
    @Published var concepts: [Concept] = [
        
    ]
    
//    Concept(
//        conceptTitle: "Software Design Principles",
//        descriptionOfConcept: "Fundamental guidelines for designing effective, maintainable, and scalable system architectures.",
//        overlapRatingOutOfTen: 8
//    ),
//    Concept(
//        conceptTitle: "System Scalability",
//        descriptionOfConcept: "Ability of a system to handle growing amounts of work in a graceful manner, accommodating increased demand for resources.",
//        overlapRatingOutOfTen: 7
//    ),
//    Concept(
//        conceptTitle: "System Reliability",
//        descriptionOfConcept: "Ability of a system to operate consistently without failures, ensuring continuous availability and smooth functioning.",
//        overlapRatingOutOfTen: 6
//    )
    
    @Published var learningObjectives: [LearningObjective] = [
        
    ]
    
//    LearningObjective(description: "Learn the fundamental guidelines for designing effective, maintainable, and scalable system architectures.", objectiveTitle: "Understand Software Design Principles"),
//    LearningObjective(description: "Discover the factors contributing to system scalability and the techniques to handle growing amounts of work, accommodating increased demand for resources.", objectiveTitle: "Explore System Scalability"),
//    LearningObjective(description: "Enhance the ability of a system to operate consistently without failures, ensuring continuous availability and smooth functioning.", objectiveTitle: "Improve System Reliability")
    
    @Published var courseOverviewSuggestions: [CourseOverview] = [
        
    ]
    
//    CourseOverview(courseTitle: "Mastering Software Design and Scalability", courseDescription: "A comprehensive course that covers essential design principles for building optimized and scalable system architectures, while emphasizing reliability and maintainability."),
//    CourseOverview(courseTitle: "Architecting Scalable and Reliable Systems", courseDescription: "Build high-quality software systems by understanding the key design principles, ensuring continuous availability, and effectively handling system growth."),
//    CourseOverview(courseTitle: "Designing Resilient and Scalable Software Systems", courseDescription: "Learn to create system architectures that can accommodate growth in demand, maintain consistent performance, and maximize uptime through reliable design strategies."),
//    CourseOverview(courseTitle: "Principles of Effective Software Design and Scalability", courseDescription: "Develop the skills to design robust, scalable, and dependable software systems by mastering fundamental principles and learning techniques that ensure growth and consistency."),
//    CourseOverview(courseTitle: "Building High-Performance Scalable Systems", courseDescription: "Understand the principles of excellent software design and learn how to create reliable and scalable system architectures that can handle increased demand for resources.")
        
    @Published var prerequisites: [Prerequisite] = [
        
    ]
    
//    Prerequisite(prerequisiteDescription: "Familiarity with at least one programming language and standard programming concepts, such as variables, loops, and functions.", prerequisiteTitle: "Basic Programming Knowledge"),
//    Prerequisite(prerequisiteDescription: "Experience with the software development life cycle, including requirements gathering, design, implementation, testing, and deployment.", prerequisiteTitle: "Understanding of Software Development Process"),
//    Prerequisite(prerequisiteDescription: "Familiarity with common software design patterns and their applications in solving common software engineering problems.", prerequisiteTitle: "Software Design Patterns"),
//    Prerequisite(prerequisiteDescription: "Knowledge of basic computer science fundamentals, such as data structures and algorithms, is necessary for understanding advanced architectural concepts.", prerequisiteTitle: "Computer Science Fundamentals")
    
    @Published var selectedCourseIndex = -1
    
    @Published var gradeLevel: String = ""
    
    @Published var courseAssessments: [Assessment] = [
        Assessment(assessmentType: "Assignments", assessmentCount: 5, percentageOfFinalGrade: -1),
        Assessment(assessmentType: "Quizzes", assessmentCount: 5, percentageOfFinalGrade: -1),
        Assessment(assessmentType: "Labs", assessmentCount: 5, percentageOfFinalGrade: -1),
        Assessment(assessmentType: "Midterms", assessmentCount: 1, percentageOfFinalGrade: -1),
        Assessment(assessmentType: "Projects", assessmentCount: 1, percentageOfFinalGrade: -1),
        Assessment(assessmentType: "Final Exam", assessmentCount: 1, percentageOfFinalGrade: -1)
    ]
    
    @Published var timingStructure: TimingStructure = TimingStructure(courseDurationInWeeks: 15, classLengthInMinutes: 60, classesPerWeek: 3, studyHoursPerWeek: 10)
    
    @Published var loading = false
    @Published var errorOcurred = false
    
    
    init() {
        $gradeLevel
            .sink { [weak self] title in
                if title.count > 3 {
                    self?.gradeLevelValid = true
                } else {
                    self?.gradeLevelValid = false
                }
            }.store(in: &cancellables)
    }
    
    func generateRelevantTextbooks() {
        self.loading = true
        courseDef.generateTextbooksFromUserPrompt(userPrompt: self.userPrompt)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("AddCoursePopUpViewModel: Failed to generate textbooks")
                    print("AddCoursePopUpViewModel-err: \(e)")
                    self?.loading = false
                case .finished:
                    print("AddCoursePopUpViewModel: Finished to generating textbooks")
                }
            } receiveValue: {[weak self] textbooks in
                self?.textbooks = textbooks.textbooks
                self?.loading = false
            }.store(in: &cancellables)
    }
    
    func findTextbookOverlap() {
        self.loading = true
        courseDef.findTextbookOverlap(textbooks: textbooks)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("AddCoursePopUpViewModel: Failed to get textbook overlap")
                    print("AddCoursePopUpViewModel-err: \(e)")
                    
                    withAnimation {
                        self?.errorOcurred = true
                        self?.loading = false
                    }
                case .finished:
                    print("AddCoursePopUpViewModel: Success")
                }
            } receiveValue: { [weak self] c in

                let sortedConcepts = c.concepts.sorted { $0.overlapRatingOutOfTen > $1.overlapRatingOutOfTen }
                
                withAnimation {
                    self?.concepts = sortedConcepts
                    self?.loading = false
                }
            }.store(in: &cancellables)
    }
    
    func getLearningObjectives() {
        self.loading = true
        if self.concepts.count != 0 {
            courseDef.getLearningObjectives(concepts: self.concepts)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("AddCoursePopUpViewModel: Failed to get learning objectives")
                        print("AddCoursePopUpViewModel: \(e)")
                        
                        withAnimation {
                            self?.errorOcurred = true
                            self?.loading = false
                        }
                    case .finished:
                        print("AddCoursePopUpViewModel.getLearningObjectives: Success")
                    }
                } receiveValue: { [weak self] objectives in
                    withAnimation {
                        self?.learningObjectives = objectives.learningObjectives
                        self?.loading = false
                    }
                }.store(in: &cancellables)
        }
    }
    
    func getCourseTitleSuggestion() {
            
        if self.learningObjectives.count != 0 {
            self.loading = true
            courseDef.getCourseTitleSuggestion(learningObjectives: self.learningObjectives)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("courseDef.getCourseTitleSuggestion: Failed")
                        print("courseDef.getCourseTitleSuggestion: \(e)")
                        
                        withAnimation {
                            self?.errorOcurred = true
                            self?.loading = false
                        }
                    case .finished:
                        print("courseDef.getCourseTitleSuggestion: Success")
                    }
                } receiveValue: { [weak self] suggestions in
                    withAnimation {
                        self?.courseOverviewSuggestions = suggestions.courseOverview
                        self?.loading = false
                    }
                }.store(in: &cancellables)
            
        } else {
            print("Get learning objectives first")
        }
    }
    
    func getPrerequisites() {
        if textbooks.count > 0 && learningObjectives.count > 0 && courseOverviewSuggestions.count > 0 && selectedCourseIndex > -1{
            let selectedCourse = courseOverviewSuggestions[selectedCourseIndex]
            
            // Clear all other courses
            courseOverviewSuggestions.removeAll()
            
            // Append selected course back into array
            courseOverviewSuggestions.append(selectedCourse)
            
            selectedCourseIndex = 0
            
            let input = PrerequisitesInput(textbooks: textbooks, learningObjectives: learningObjectives, courseOverview: courseOverviewSuggestions[0])
            
            self.loading = true
            
            courseDef.getPrerequisites(input: input)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let e):
                        print("courseDef.getCourseTitleSuggestion: Failed")
                        print("courseDef.getCourseTitleSuggestion: \(e)")
                        
                        withAnimation {
                            self?.errorOcurred = true
                            self?.loading = false
                        }
                    case .finished:
                        print("courseDef.getCourseTitleSuggestion: Success")
                    }
                } receiveValue: { [weak self] prereqs in
                    withAnimation {
                        self?.prerequisites = prereqs.prerequisites
                        self?.loading = false
                    }
                }.store(in: &cancellables)
        }
    }
}

extension AddCoursePopUpViewModel {
    func resetAllAIGenerated() {
        textbooks = []
        concepts = []
        learningObjectives = []
        courseOverviewSuggestions = []
        prerequisites = []
    }
    
    func resetUserInput() {
        gradeLevel = ""
        
        courseAssessments = [
            Assessment(assessmentType: "Assignments", assessmentCount: 5, percentageOfFinalGrade: -1),
            Assessment(assessmentType: "Quizzes", assessmentCount: 5, percentageOfFinalGrade: -1),
            Assessment(assessmentType: "Labs", assessmentCount: 5, percentageOfFinalGrade: -1),
            Assessment(assessmentType: "Midterms", assessmentCount: 1, percentageOfFinalGrade: -1),
            Assessment(assessmentType: "Projects", assessmentCount: 1, percentageOfFinalGrade: -1),
            Assessment(assessmentType: "Final Exam", assessmentCount: 1, percentageOfFinalGrade: -1)
        ]
        
        timingStructure = TimingStructure(courseDurationInWeeks: 15, classLengthInMinutes: 60, classesPerWeek: 3, studyHoursPerWeek: 10)
        selectedClassType = ClassType(id: "Computer Science", sfSymbol: "desktopcomputer")
    }
    
    func resetAll() {
        resetAllAIGenerated()
        resetUserInput()
    }
}
