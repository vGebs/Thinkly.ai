//
//  Class.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import FirebaseFirestoreSwift

struct Class: FirestoreProtocol {
    @DocumentID var documentID: String?
    var title: String
    var sfSymbol: String
    var description: String
    var startDate: Date
    var endDate: Date
    
    var teacherID: String
}
