//
//  CourseDefinitionService.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-10.
//

import Foundation
import Combine

class CourseDefinitionService {
    let networkWrapper: NetworkWrapperCombine
    let baseURL = URL(string: "http://172.16.1.154:3000/courseDefinition")!

    public init(networkWrapper: NetworkWrapperCombine = .init()) {
        self.networkWrapper = networkWrapper
    }
    
    public func findTextbookOverlap(textbooks: [Textbook]) -> AnyPublisher<ConceptResponse, Error> {
        let url = baseURL.appendingPathComponent("/findTextbookOverlap")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(textbooks)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request)
    }
    
    public func getLearningObjectives(concepts: [Concept]) -> AnyPublisher<LearningObjectives, Error> {
        let url = baseURL.appendingPathComponent("/getLearningObjectives")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(concepts)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request)
    }
    
    public func getCourseTitleSuggestion(learningObjectives: [LearningObjective]) -> AnyPublisher<CourseOverviewSuggestions, Error> {
        let url = baseURL.appendingPathComponent("/getCourseTitleSuggestion")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(learningObjectives)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request)
    }
    
    public func getPrerequisites(input: PrerequisitesInput) -> AnyPublisher<Prerequisites, Error> {
        let url = baseURL.appendingPathComponent("/getPrerequisites")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(input)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request)
    }
}


struct ConceptResponse: Codable {
    let concepts: [Concept]
}

struct LearningObjectives: Codable {
    let learningObjectives: [LearningObjective]
}

struct CourseOverviewSuggestions: Codable {
    let courseOverview: [CourseOverview]
}

struct Prerequisites: Codable {
    let prerequisites: [Prerequisite]
}

struct PrerequisitesInput: Codable {
    let textbooks: [Textbook]
    let learningObjectives: [LearningObjective]
    let courseOverview: CourseOverview
}
