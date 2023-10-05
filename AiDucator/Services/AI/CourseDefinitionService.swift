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
//    let baseURL = URL(string: "http://172.16.1.154:3000/courseDefinition")!
//    let pingURL = URL(string: "http://172.16.1.154:3000/ping")!
    
    @Published var baseURL: URL?
    @Published var pingURL: URL?
    
    private var cancellables: [AnyCancellable] = []
    
    enum URLError: Error {
        case noBaseURL
    }
    
    public init(networkWrapper: NetworkWrapperCombine = .init()) {
        self.networkWrapper = networkWrapper
        
        AppState.shared.$backend_BaseUrl
            .sink { [weak self] url in
                if let url = url {
                    self?.baseURL = url.appendingPathComponent("/courseDefinition")
                    self?.pingURL = url.appendingPathComponent("/ping")
                }
            }.store(in: &cancellables)
        
    }
    
    private func bundlePingRequest() -> URLRequest? {
        if let pingURL = pingURL {
            var request = URLRequest(url: pingURL)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
        
        return nil
    }
    
    public func getCourseTitleSuggestionsFromCurriculum(from curriculum: CourseTitleSuggestionInput) -> AnyPublisher<CourseOverviewSuggestions, Error> {
        if let baseURL = baseURL {
            let url = baseURL.appendingPathComponent("/getCourseTitleSuggestionFromCurriculum")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(curriculum)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
        } else {
            return Fail(error: URLError.noBaseURL).eraseToAnyPublisher()
        }
    }
    
    public func getCourseTitleSuggestion(learningObjectives: [LearningObjective]) -> AnyPublisher<CourseOverviewSuggestions, Error> {
        if let baseURL = baseURL {
            let url = baseURL.appendingPathComponent("/getCourseTitleSuggestion")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(learningObjectives)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
        } else {
            return Fail(error: URLError.noBaseURL).eraseToAnyPublisher()
        }
    }
    
//    func generateTextbooksFromUserPrompt(userPrompt: String) -> AnyPublisher<Textbooks, Error> {
//        let url = baseURL.appendingPathComponent("/generateTextbooksFromUserPrompt")
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(userPrompt)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
//    }
    
//    func generateLearningObjectiveFromUserPrompt(userPrompt: String) -> AnyPublisher<LearningObjectives, Error> {
//        let url = baseURL.appendingPathComponent("/generateLearningObjectiveFromUserPrompt")
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(userPrompt)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
//    }
    
//    public func findTextbookOverlap(textbooks: [Textbook]) -> AnyPublisher<ConceptResponse, Error> {
//        let url = baseURL.appendingPathComponent("/findTextbookOverlap")
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(textbooks)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
//    }
    
//    public func getLearningObjectives(concepts: [Concept]) -> AnyPublisher<LearningObjectives, Error> {
//        let url = baseURL.appendingPathComponent("/getLearningObjectives")
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(concepts)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
//    }
    
//    public func getPrerequisites(input: PrerequisitesInput) -> AnyPublisher<Prerequisites, Error> {
//        let url = baseURL.appendingPathComponent("/getPrerequisites")
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(input)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
//    }
}

struct CourseTitleSuggestionInput: Codable {
    let uid: String
    let units: [Unit]
}

struct ConceptResponse: Codable {
    let concepts: [Concept]
}

struct LearningObjectives: Codable {
    let learningObjectives: [LearningObjective]
}

struct CourseOverviewSuggestions: Codable {
    let courseOverview: [CourseOverviewGenerated]
}

struct CourseOverviewGenerated: Codable {
    let courseTitle: String
    let courseDescription: String
}

struct Prerequisites: Codable {
    let prerequisites: [Prerequisite]
}

struct PrerequisitesInput: Codable {
    let textbooks: [Textbook]
    let learningObjectives: [LearningObjective]
    let courseOverview: CourseOverview
}

struct Textbooks: Codable {
    let textbooks: [Textbook]
}
