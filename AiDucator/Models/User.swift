//
//  User.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import FirebaseFirestoreSwift

//Ok, so we need to have a data transfer object
//The UserFirestore object will be how the data is stored in firestore
//The User object will be how the data is stored in memory
//
//When we are creating a new object, we will use the firestore object
//When we fetch the object, we will then fetch the classes and store those inside of the User object

struct UserFirestore: FirestoreProtocol {
    @DocumentID var documentID: String?
    
    var name: String
    var role: String
    var uid: String
    var birthdate: Date
}

struct User {
    var documentID: String
    
    var name: String
    var role: String
    var uid: String
    var birthdate: Date
    
    var classes: [Class]?
}
