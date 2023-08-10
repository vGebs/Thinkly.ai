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
    
    func getCurriculum(prompt: String) -> AnyPublisher<CurriculumOutput, Error> {
        let url = baseURL.appendingPathComponent("/generateCurriculum")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(prompt)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
    
    func getSubUnits(_ input: GetSubUnits) -> AnyPublisher<SubUnits, Error> {
        let url = baseURL.appendingPathComponent("/generateSubTopicsForUnit")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(input)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
    
    func generateLessonsForSubunit(_ input: GetLessons) -> AnyPublisher<Lessons, Error> {
        let url = baseURL.appendingPathComponent("/generateLessonsForSubunit")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(input)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
    
    func generateNotes(input: NotesInput) ->AnyPublisher<Notes, Error> {
        let url = baseURL.appendingPathComponent("/generateNotesForLesson")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(input)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
}

struct NotesInput: Codable {
    var lessonNumber: String
    var unit: Unit
}

//struct NotesOutput: Codable {
//    var notes: Notes
//}

struct GetLessons: Codable {
    var curriculum: [Unit]
    var subunitNumber: Double
}

struct GetSubUnits: Codable {
    var unitNumber: Int
    var curriculum: [Unit]
}

struct SubUnits: Codable {
    var subUnits: [SubUnit]
}

struct Lessons: Codable {
    var lessons: [Lesson]
}

struct Lesson: Codable {
    var lessonNumber: String
    var lessonDescription: String
    var lessonTitle: String
    var notes: Notes? = nil
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
    var subUnits: [SubUnit]? = nil
}

struct SubUnit: Codable {
    var unitNumber: Double
    var unitDescription: String
    var unitTitle: String
    var lessons: [Lesson]? = nil
    var assignment: Assignment? = nil 
}

struct CurriculumOutput: Codable {
    var units: [Unit]
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
