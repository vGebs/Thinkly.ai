//
//  ClassService_CoreData.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine
import CoreData

class ClassService_CoreData {
    
    private let coreData: CoreDataWrapper
    
    init(model: CoreDataWrapper) {
        self.coreData = model
    }
    
    func addClass(cls: Class, docID: String?) {
        let newCls = coreData.create(objectType: ClassEntity.self)
        
        newCls.title = cls.title
        newCls.courseDescription = cls.description
        newCls.startDate = cls.startDate
        newCls.endDate = cls.endDate
        newCls.sfSymbol = cls.sfSymbol
        newCls.teacherID = cls.teacherID
        newCls.documentID = docID
        
        save()
    }
    
    func fetchClass(with docID: String) -> Class? {
        if let classCD = fetchBasic(with: docID) {
            return toBasic(cls: classCD)
        }
        return nil
    }
    
    func fetchClasses(for teacherID: String) -> [Class]? {
        let fetchRequest = NSFetchRequest<ClassEntity>(entityName: "ClassEntity")
        fetchRequest.predicate = NSPredicate(format: "teacherID == %@", teacherID)
        do {
            let clsArr = try coreData.fetch(fetchRequest: fetchRequest)
            
            if clsArr.count == 0 {
                return nil
            }
            
            var returnedArray: [Class] = []
            
            for cls in clsArr {
                returnedArray.append(toBasic(cls: cls))
            }
            
            return returnedArray
        } catch {
            print("ClassService_CoreData: Failed to fetch class")
            print("ClassService_CoreData-err: \(error)")
            return nil
        }
    }
    
    func updateClass(cls: Class) {
        //we need to first fetch the object
        if let docID = cls.documentID {
            var classCD = fetchBasic(with: docID)
            
            if let _ = classCD {
                classCD!.documentID = docID
                classCD!.title = cls.title
                classCD!.startDate = cls.startDate
                classCD!.endDate = cls.endDate
                classCD!.sfSymbol = cls.sfSymbol
                classCD!.teacherID = cls.teacherID
                classCD!.courseDescription = cls.description
                
                save()
            }
        }
        print("ClassService_CoreData: no document ID")
    }
    
    func deleteClass(with docID: String) {
        var classCD = fetchBasic(with: docID)
        
        if let _ = classCD {
            do {
                try coreData.delete(object: classCD!)
            } catch {
                print("ClassService_CoreData: Failed to delete class with docID: \(docID)")
                print("ClassService_CoreData-err: \(error)")
            }
        } else {
            print("ClassService_CoreData: No class with that ID")
        }
    }
    
    func clearCache() {
        do {
            try coreData.clearCache()
        } catch {
            print("ClassService_CoreData: Failed to clear cache")
            print("ClassService_CoreData: \(error)")
        }
    }
}

extension ClassService_CoreData {
    private func fetchBasic(with docID: String) -> ClassEntity? {
        let fetchRequest = NSFetchRequest<ClassEntity>(entityName: "ClassEntity")
        fetchRequest.predicate = NSPredicate(format: "documentID == %@", docID)
        do {
            let clsArr = try coreData.fetch(fetchRequest: fetchRequest)
            
            if clsArr.count == 0 {
                return nil
            }
            
            return clsArr[0]
        } catch {
            print("ClassService_CoreData: Failed to fetch class")
            print("ClassService_CoreData-err: \(error)")
            return nil
        }
    }
    
    private func save() {
        do {
            try coreData.saveContext()
        } catch {
            print("ClassService_CoreData: Failed to save")
            print("ClassService_CoreData: \(error)")
        }
    }
    
    private func toBasic(cls: ClassEntity) -> Class {
        
        let newCls = Class(documentID: cls.documentID, title: cls.title!, sfSymbol: cls.sfSymbol!, description: cls.courseDescription!, startDate: cls.startDate!, endDate: cls.endDate!, teacherID: cls.teacherID!)
        
        return newCls
    }
}
