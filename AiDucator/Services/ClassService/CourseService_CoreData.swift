//
//  CourseService_CoreData.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import Foundation
import Combine
import CoreData

//class CourseService_CoreData {
//    
//    private let coreData: CoreDataWrapper
//    
//    init(model: CoreDataWrapper) {
//        self.coreData = model
//    }
//    
//    func addCourse(course: Course, docID: String?) {
//        let newCourse = coreData.create(objectType: ClassEntity.self)
//        
//        newCourse.title = course.title
//        newCourse.courseDescription = course.description
//        newCourse.startDate = course.startDate
//        newCourse.endDate = course.endDate
//        newCourse.sfSymbol = course.sfSymbol
//        newCourse.teacherID = course.teacherID
//        newCourse.documentID = docID
//        
//        save()
//    }
//    
//    func fetchCourse(with docID: String) -> Course? {
//        if let CourseCD = fetchBasic(with: docID) {
//            return toBasic(cls: CourseCD)
//        }
//        return nil
//    }
//    
//    func fetchCourses(for teacherID: String) -> [Course]? {
//        let fetchRequest = NSFetchRequest<ClassEntity>(entityName: "ClassEntity")
//        fetchRequest.predicate = NSPredicate(format: "teacherID == %@", teacherID)
//        do {
//            let clsArr = try coreData.fetch(fetchRequest: fetchRequest)
//            
//            if clsArr.count == 0 {
//                return nil
//            }
//            
//            var returnedArray: [Course] = []
//            
//            for cls in clsArr {
//                returnedArray.append(toBasic(cls: cls))
//            }
//            
//            return returnedArray
//        } catch {
//            print("CourseService_CoreData: Failed to fetch class")
//            print("CourseService_CoreData-err: \(error)")
//            return nil
//        }
//    }
//    
//    func updateCourse(course: Course) {
//        //we need to first fetch the object
//        if let docID = course.documentID {
//            let courseCD = fetchBasic(with: docID)
//            
//            if let _ = courseCD {
//                courseCD!.documentID = docID
//                courseCD!.title = course.title
//                courseCD!.startDate = course.startDate
//                courseCD!.endDate = course.endDate
//                courseCD!.sfSymbol = course.sfSymbol
//                courseCD!.teacherID = course.teacherID
//                courseCD!.courseDescription = course.description
//                
//                save()
//            }
//        }
//        print("CourseService_CoreData: no document ID")
//    }
//    
//    func deleteCourse(with docID: String) {
//        let courseCD = fetchBasic(with: docID)
//        
//        if let _ = courseCD {
//            do {
//                try coreData.delete(object: courseCD!)
//            } catch {
//                print("CourseService_CoreData: Failed to delete Course with docID: \(docID)")
//                print("CourseService_CoreData-err: \(error)")
//            }
//        } else {
//            print("CourseService_CoreData: No Course with that ID")
//        }
//    }
//    
//    func clearCache() {
//        do {
//            try coreData.clearCache()
//        } catch {
//            print("CourseService_CoreData: Failed to clear cache")
//            print("CourseService_CoreData: \(error)")
//        }
//    }
//}
//
//extension CourseService_CoreData {
//    private func fetchBasic(with docID: String) -> ClassEntity? {
//        let fetchRequest = NSFetchRequest<ClassEntity>(entityName: "ClassEntity")
//        fetchRequest.predicate = NSPredicate(format: "documentID == %@", docID)
//        do {
//            let clsArr = try coreData.fetch(fetchRequest: fetchRequest)
//            
//            if clsArr.count == 0 {
//                return nil
//            }
//            
//            return clsArr[0]
//        } catch {
//            print("CourseService_CoreData: Failed to fetch course")
//            print("CourseService_CoreData-err: \(error)")
//            return nil
//        }
//    }
//    
//    private func save() {
//        do {
//            try coreData.saveContext()
//        } catch {
//            print("CourseService_CoreData: Failed to save")
//            print("CourseService_CoreData: \(error)")
//        }
//    }
//    
//    private func toBasic(cls: ClassEntity) -> Course {
//        
//        let newCls = Course(documentID: cls.documentID, title: cls.title!, sfSymbol: cls.sfSymbol!, description: cls.courseDescription!, startDate: cls.startDate!, endDate: cls.endDate!, teacherID: cls.teacherID!)
//        
//        return newCls
//    }
//}
