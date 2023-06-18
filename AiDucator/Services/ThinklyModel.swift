//
//  CoreDataStore.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-14.
//

import Foundation
import CoreData

class ThinklyModel {
    
    static let shared = ThinklyModel()
    
    let model: CoreDataWrapper
    
    let userService: UserService_CoreData
    //let courseService: CourseService_CoreData
    
    private init() {
        let storeURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("ThinklyModel.sqlite")
        model = CoreDataWrapper(modelName: "ThinklyModel", storeURL: storeURL)
        
        self.userService = UserService_CoreData(model: model)
        //self.courseService = CourseService_CoreData(model: model)
    }
}
