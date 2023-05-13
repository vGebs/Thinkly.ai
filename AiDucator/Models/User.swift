//
//  User.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import FirebaseFirestoreSwift

struct User: FirestoreProtocol {
    @DocumentID var documentID: String?
    
    var name: String
    var role: String
    var uid: String
    var birthdate: Date
}
