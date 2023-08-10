//
//  Notes.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-20.
//

import Foundation
import FirebaseFirestoreSwift

// Note model
struct Note: Identifiable {
    let id = UUID()
    var title: String
    var content: String
}

// Chapter model
struct Chapter: Identifiable {
    let id = UUID()
    var title: String
    var notes: [Note]
}

// /Notes/noteId
//   - title
//   - teacherId
//   - timestamp
//   - numSections
//   - classId
//   - content  (optional)

// /NoteSections/sectionId
//   - order
//   - content

//struct Notes: FirestoreProtocol {
//    @DocumentID var documentID: String?
//    var title: String
//    var teacherID: String
//    var timestamp: Date
//    var numSections: Int
//    var classID: String
//    var content: String?
//}

//struct NoteSection: FirestoreProtocol {
//    @DocumentID var documentID: String?
//    var noteID: String
//    var index: Int
//    var content: String
//}

struct Notes: Codable {
    var notes: [Paragraph]
    var docID: String?
}

struct Paragraph: Codable {
    var paragraph: String
}
