//
//  UserService_CoreData.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import CoreData
import Combine

class UserService_CoreData {
    
    private let coreData: CoreDataWrapper
    
    init(model: CoreDataWrapper) {
        self.coreData = model
    }
    
    func createUser(_ user: User, docID: String?) {
        let userCheck = fetchUser_(uid: user.uid)
        
        if userCheck == nil {
            let newUser = coreData.create(objectType: UserEntity.self)
            
            newUser.docID = docID
            newUser.name = user.name
            newUser.role = user.role
            newUser.uid = user.uid
            newUser.birthdate = user.birthdate
            
            self.saveContext()
        } else {
            print("UserService_CoreData: User already exists")
        }
    }
    
    func fetchUser(uid: String) -> User? {
        let userCD = fetchUser_(uid: uid)
        
        if let u = userCD {
            return User(documentID: u.docID, name: u.name!, role: u.role!, uid: u.uid!, birthdate: u.birthdate!)
        } else {
            return nil
        }
    }
    
    func updateUser(user: User) {
        let userCD = fetchUser_(uid: user.uid)
        
        guard userCD != nil else {
            print("UserService_CoreData: Failed to update user")
            print("UserService_CoreData: User does not exist")
            return
        }
        
        userCD!.uid = user.uid
        userCD!.name = user.name
        userCD!.docID = user.documentID
        userCD!.birthdate = user.birthdate
        userCD!.role = user.role
        
        self.saveContext()
    }
    
    func deleteUser(uid: String) {
        let user = fetchUser_(uid: uid)
        if let u = user {
            do {
                try coreData.delete(object: u.self)
                print("UserService_CoreData: Successfully deleted user with uid: \(uid)")
            } catch {
                print("UserService_CoreData: Failed to delete user")
            }
        } else {
            
        }
    }
}

extension UserService_CoreData {
    
    private func fetchUser_(uid: String) -> UserEntity? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let userCD = try coreData.fetch(fetchRequest: fetchRequest)
            if userCD.count == 0 {
                return nil
            } else {
                return userCD[0]
            }
        } catch {
            print("UserService_CoreData: Failed to fetch user")
            print("UserService_CoreData: \(error)")
            return nil
        }
    }
    
    private func saveContext() {
        do {
            try coreData.saveContext()
        } catch {
            print("UserService_CoreData: Failed to save context")
            print("UserService_CoreData: \(error)")
        }
    }
}
