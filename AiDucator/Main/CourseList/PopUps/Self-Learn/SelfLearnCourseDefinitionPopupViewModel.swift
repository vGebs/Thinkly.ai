//
//  SelfLearnCourseDefinitionPopupViewModel.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-25.
//

import Foundation
import Combine
import SwiftUI

class SelfLearnCourseDefinitionViewModel: ObservableObject {
    @Published var userPrompt = "I want to learn about software architecture, especially to do with high volume applications and system design"
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
    
    @Published var selectedCourseIndex = -1
    @Published var selectedClassType = ClassType(id: "Computer Science", sfSymbol: "desktopcomputer")
    var courseDefService: CourseDefinitionService
    @Published var loading = false 
    
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.courseDefService = CourseDefinitionService()
    }
    
    func generateLearningObjectives() {
        if userPrompt.count > 14 {
            self.loading = true
            courseDefService.generateLearningObjectiveFromUserPrompt(userPrompt: userPrompt)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("SelfLearnCourseDefinitionViewModel: Finished getting learning objectives from user prompt")
                    case .failure(let e):
                        print("SelfLearnCourseDefinitionViewModel: Failed getting learning objectives from user prompt")
                        print("SelfLearnCourseDefinitionViewModel-err: \(e)")
                        self.loading = false
                    }
                } receiveValue: { learningObjectives in
                    self.learningObjectives = learningObjectives.learningObjectives
                    self.loading = false
                }.store(in: &cancellables)

        }
    }
    
    func getCourseTitleSuggestion() {
        self.loading = true
        courseDefService.getCourseTitleSuggestion(learningObjectives: self.learningObjectives)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("SelfLearnCourseDefinitionViewModel: Failed to get course title suggestions")
                    print("SelfLearnCourseDefinitionViewModel: \(e)")
                    
                    withAnimation {
//                        self?.errorOcurred = true
                        self?.loading = false
                    }
                case .finished:
                    print("SelfLearnCourseDefinitionViewModel: Finished getting course title suggestions")
                }
            } receiveValue: { [weak self] suggestions in
                withAnimation {
                    self?.courseOverviewSuggestions = suggestions.courseOverview
                    self?.loading = false
                }
            }.store(in: &cancellables)
    }
    
    func resetAll() {
        self.userPrompt = ""
        self.learningObjectives = []
        self.courseOverviewSuggestions = []
        self.selectedCourseIndex = -1
    }
}

