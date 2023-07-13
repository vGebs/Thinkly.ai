//
//  CourseDefinition.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-08.
//

import Foundation
import FirebaseFirestoreSwift

struct CourseDefinition: Codable, FirestoreProtocol {
    @DocumentID var documentID: String?
    let courseFull: CourseFull
    let teacherID: String
    var sfSymbol: String
}

struct CourseFull: Codable {
    var courseAssessments: [Assessment]? = nil
    var courseTimingStructure: TimingStructure? = nil
    var gradeLevel: String? = nil
    var textbooks: [Textbook]? = nil
    var learningObjectives: [LearningObjective]
    var courseOverview: CourseOverview
    var prerequisites: [Prerequisite]? = nil 
    var weeklyContents: [WeeklyContent]? = nil
}

struct Assessment: Codable {
    let assessmentType: String
    var assessmentCount: Int
    var percentageOfFinalGrade: Int
}

struct TimingStructure: Codable {
    var courseDurationInWeeks: Int
    var classLengthInMinutes: Int
    var classesPerWeek: Int
    var studyHoursPerWeek: Int
}

struct Textbook: Codable {
    var title: String
    var author: String
}

struct LearningObjective: Codable {
    let objectiveDescription: String
    let objectiveTitle: String
}

struct CourseOverview: Codable {
    let courseTitle: String
    let courseDescription: String
}

struct Prerequisite: Codable {
    let prerequisiteDescription: String
    let prerequisiteTitle: String
}

struct WeeklyContent: Codable, Identifiable {
    var id = UUID().uuidString
    let notesOutline: [NoteOutline]
    let assessments: [WeekAssessment]
    let topics: [Topic]
    let week: Int
    let classOutline: [ClassOutline]
}

struct NoteOutline: Codable {
    let heading: String
    let subtopics: [Subtopic]
}

struct Subtopic: Codable {
    let heading: String
    let subtopics: [Subtopic]
    let content: String?
}

struct WeekAssessment: Codable {
    let assessmentDescription: String
    let assessmentTitle: String
    let assessmentType: String
}

struct Topic: Codable, Identifiable {
    var id = UUID().uuidString
    let readings: [Reading]
    let topicName: String
}

struct Reading: Codable, Identifiable {
    var id = UUID().uuidString
    let chapter: Int
    let textbook: Textbook
}

struct ClassOutline: Codable {
    let classNumber: Int
    let classProcedure: [ClassProcedure]
    let learningObjectives: [String]
    let requiredMaterials: [String]
}

struct ClassProcedure: Codable {
    let activity: String
    let time: String
}

struct Concept: Codable {
    var conceptTitle: String
    var descriptionOfConcept: String
    var overlapRatingOutOfTen: Int
}
