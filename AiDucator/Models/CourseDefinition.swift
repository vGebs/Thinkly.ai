//
//  CourseDefinition.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-08.
//

import Foundation

struct CourseFull: Codable {
    let courseAssessments: [Assessment]
    let courseTimingStructure: TimingStructure
    let gradeLevel: String
    let textbooks: [Textbook]
    let learningObjectives: [LearningObjective]
    let courseOverview: CourseOverview
    let prerequisites: [Prerequisite]
    let weeklyContents: [WeeklyContent]
}

struct Assessment: Codable {
    let assessmentType: String
    let assessmentCount: Int
    let percentageOfFinalGrade: Int
}

struct TimingStructure: Codable {
    let courseDurationInWeeks: Int
    let classLengthInHours: Int
    let classesPerWeek: Int
    let studyHoursPerWeek: Int
}

struct Textbook: Codable {
    var title: String
    var author: String
}

struct LearningObjective: Codable {
    let description: String
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

struct WeeklyContent: Codable {
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

struct Topic: Codable {
    let readings: [Reading]
    let topicName: String
}

struct Reading: Codable {
    let chapter: Int
    let textbook: String
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
