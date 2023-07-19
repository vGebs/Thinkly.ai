//
//  CourseCreationService.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-10.
//

import Foundation
import Combine
import FirebaseFirestoreSwift

public class CourseCreationService {
    private let networkWrapper: NetworkWrapperCombine
    let baseURL = URL(string: "http://172.16.1.154:3000/courseCreation")!
    let pingURL = URL(string: "http://172.16.1.154:3000/ping")!

    public init(networkWrapper: NetworkWrapperCombine = .init()) {
        self.networkWrapper = networkWrapper
    }
    
    private func bundlePingRequest() -> URLRequest {
        var request = URLRequest(url: pingURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func getCurriculum(prompt: String) -> AnyPublisher<Curriculum, Error> {
        let url = baseURL.appendingPathComponent("/generateCurriculum")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(prompt)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
    
    func getWeeklyContent(data: WeeklyContentInput) -> AnyPublisher<WeeklyContent, Error> {
        let url = URL(string: "/courseCreation/getWeeklyContent")! // Replace with your server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        return networkWrapper.request(with: request, timeout: 120)
    }
    
    func updateWeekContent(data: WeeklyContentInput) -> AnyPublisher<WeeklyContent, Error> {
        let url = URL(string: "/courseCreation/updateWeekContent")! // Replace with your server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        return networkWrapper.request(with: request, timeout: 120)
    }
    
    func getClassOutline(data: WeeklyContentInput) -> AnyPublisher<ClassOutline, Error> {
        let url = URL(string: "/courseCreation/getClassOutline")! // Replace with your server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        return networkWrapper.request(with: request, timeout: 120)
    }
    
    func getNotesOutlineForTopic(data: NotesOutlineInput) -> AnyPublisher<[NoteOutline], Error> {
        let url = URL(string: "/courseCreation/getNotesOutlineForTopic")! // Replace with your server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        return networkWrapper.request(with: request, timeout: 120)
    }
    
    func getOutlineForSubtopic(data: OutlineForSubtopicInput) -> AnyPublisher<Subtopic, Error> {
        let url = URL(string: "/courseCreation/getOutlineForSubtopic")! // Replace with your server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        return networkWrapper.request(with: request, timeout: 120)
    }
    
//    public func getOutlineForSubSubtopic(data: [String: Any]) -> AnyPublisher<[String: Any], Error> {
//        let url = URL(string: "/courseCreation/getOutlineForSubSubtopic")! // Replace with your server URL
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
//        return networkWrapper.request(with: request)
//    }
//
//    public func writeContentForSubtopic(data: [String: Any]) -> AnyPublisher<[String: Any], Error> {
//        let url = URL(string: "/courseCreation/writeContentForSubtopic")! // Replace with your server URL
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
//        return networkWrapper.request(with: request)
//    }
//
//    public func addDepth(data: [String: Any]) -> AnyPublisher<[String: Any], Error> {
//        let url = URL(string: "/courseCreation/addDepth")! // Replace with your server URL
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
//        return networkWrapper.request(with: request)
//    }
}

struct PreliminaryCurriculumInput: Codable {
    var gradeLevel: String? = nil 
    var textBooks: [Textbook]
    var learningObjectives: [LearningObjective]
    var courseOverview: CourseOverview
    var prerequisites: [Prerequisite]
    var units: [Unit]
}

struct PreliminaryCurriculumWeekInput: Codable {
    var unitNumber: Int
    var totalUnits: Int
    var course: PreliminaryCurriculumInput
}

struct Unit: Codable {
    var unitNumber: Int
    var unitDescription: String
    var unitTitle: String
}

struct Curriculum: Codable, FirestoreProtocol {
    @DocumentID var documentID: String?
    var courseID: String? = nil
    var units: [Unit]
}

struct NotesOutlineInput: Codable {
    var week: Int
    var topicNumber: Int
    var topics: [Topic]
}

struct WeeklyContentInput: Codable {
    var week: Int
    var course: CourseFull
}

struct OutlineForSubtopicInput: Codable {
    var outlineIndex: Int
    var subtopicIndex: Int
    var outline: [NoteOutline]
    var readings: [Reading]
    var topicName: String
}
