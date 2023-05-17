//
//  ClassUser.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import FirebaseFirestoreSwift

struct ClassUser: FirestoreProtocol {
    @DocumentID var documentID: String?
    var classID: String
    var userID: String
}
