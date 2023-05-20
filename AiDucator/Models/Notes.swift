//
//  Notes.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-20.
//

import Foundation
import FirebaseFirestoreSwift

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

struct Notes: FirestoreProtocol {
    @DocumentID var documentID: String?
    var title: String
    var teacherID: String
    var timestamp: Date
    var numSections: Int
    var classID: String
    var content: String?
}

struct NoteSection: FirestoreProtocol {
    @DocumentID var documentID: String?
    var noteID: String
    var index: Int
    var content: String
}
