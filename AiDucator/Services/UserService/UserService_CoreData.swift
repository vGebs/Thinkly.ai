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
    
    static let shared = UserService_CoreData()
    
    private init() {
        let storeURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("ThinklyModel.sqlite")
        coreData = CoreDataWrapper(modelName: "ThinklyModel", storeURL: storeURL)
    }
    
    func createUser(_ user: User) {
        let userCheck = fetchUser_(uid: user.uid)
        
        if userCheck == nil {
            let newUser = coreData.create(objectType: UserEntity.self)
            
            newUser.docID = user.documentID
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
    
    func updateName(name: String, uid: String) {
        let userCD = fetchUser_(uid: uid)
        
        guard userCD != nil else {
            print("UserService_CoreData: Failed to update user")
            print("UserService_CoreData: User does not exist")
            return
        }
        
        userCD!.name = name
        
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
