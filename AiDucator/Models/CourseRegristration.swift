//
//  ClassUser.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import FirebaseFirestoreSwift

struct CourseRegristration: FirestoreProtocol {
    @DocumentID var documentID: String?
    var courseID: String
    var userID: String
}
