//
//  CoreDataWrapper.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import CoreData

public class CoreDataWrapper {
    private let modelName: String
    private let storeURL: URL
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("CoreDataWrapper: Unable to find Data Model: \(self.modelName)")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("CoreDataWrapper: Unable to load Data Model: \(self.modelName)")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        } catch {
            fatalError("CoreDataWrapper: Unable to add Persistent Store for: \(self.modelName)")
        }
        return persistentStoreCoordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    public init(modelName: String, storeURL: URL) {
        self.modelName = modelName
        self.storeURL = storeURL
    }
    
    public func create<T: NSManagedObject>(objectType: T.Type) -> T {
        let newObject = NSEntityDescription.insertNewObject(forEntityName: String(describing: objectType), into: managedObjectContext) as! T
        return newObject
    }
    
    public func fetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) throws -> [T] {
        let results = try managedObjectContext.fetch(fetchRequest)
        return results
    }
    
    public func saveContext() throws {
        guard managedObjectContext.hasChanges else { return }
        try managedObjectContext.save()
    }
    
    public func delete<T: NSManagedObject>(object: T) throws {
        managedObjectContext.delete(object)
        try saveContext()
    }
}
