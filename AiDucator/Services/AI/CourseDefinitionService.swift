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
    let baseURL = URL(string: "http://yourserver.com/courseDefinition")!

    public init(networkWrapper: NetworkWrapperCombine) {
        self.networkWrapper = networkWrapper
    }
    
    public func findTextbookOverlap(textbooks: [Textbook]) -> AnyPublisher<[Concept], Error> {
        let url = baseURL.appendingPathComponent("/findTextbookOverlap")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(textbooks)
        return networkWrapper.request(with: request)
    }
    
    public func getLearningObjectives(concepts: [Concept]) -> AnyPublisher<[LearningObjective], Error> {
        let url = baseURL.appendingPathComponent("/getLearningObjectives")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(concepts)
        return networkWrapper.request(with: request)
    }
    
    public func getCourseTitleSuggestion(learningObjectives: [LearningObjective]) -> AnyPublisher<[CourseOverview], Error> {
        let url = baseURL.appendingPathComponent("/getCourseTitleSuggestion")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(learningObjectives)
        return networkWrapper.request(with: request)
    }
    
    public func getPrerequisites(input: PrerequisitesInput) -> AnyPublisher<[Prerequisite], Error> {
        let url = baseURL.appendingPathComponent("/getPrerequisites")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(input)
        return networkWrapper.request(with: request)
    }
}


struct PrerequisitesInput: Codable {
    let textbooks: [Textbook]
    let learningObjectives: [LearningObjective]
    let courseOverview: CourseOverview
}
