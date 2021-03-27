//
//  LocalStorageManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import CoreData

class LocalStorageManager {
    var coreDataArticlesLimit = 200
    var coreDataImagesLimit = 20
    
    var contextLock = NSLock()
    
    func drop(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        let managedContext = self.persistentContainer.viewContext
        
        let _ = try? managedContext.execute(request)
    }
    
    func eraseToLimits(entityName: String) {
        let managedContext = self.persistentContainer.viewContext
        if let entities = load(entityName: entityName) {
            var shouldDelete = false
            switch entityName {
            case "LocalArticle":
                shouldDelete = entities.count >= coreDataArticlesLimit
            case "LocalImage" :
                shouldDelete = entities.count >= coreDataImagesLimit
            default:
                break
            }
            if shouldDelete {
                let oldestToDelete = entities
                    .sorted(by: { ($0.value(forKey: "lastAccess") as? Date ?? Date()) > ($1.value(forKey: "lastAccess") as? Date ?? Date()) })
                    .dropFirst(1)
                contextLock.lock()
                oldestToDelete.forEach({
                    managedContext.delete($0)
                })
                contextLock.unlock()
            }
        }
    }
    struct PrimaryKey {
        var key: String
        var value: Any?
    }
    func save(entityFields: [String: Any?], to entityName: String, primaryKey: PrimaryKey? = nil) {
        //TODO: add primary key constraint condition
        
        DispatchQueue.main.async {
            let managedContext = self.persistentContainer.viewContext
            
            self.eraseToLimits(entityName: entityName)
            
            let entity =
              NSEntityDescription.entity(forEntityName: entityName,
                                         in: managedContext)!
            
            let project = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            for keyValue in entityFields {
                if keyValue.value != nil {
                    project.setValue(keyValue.value, forKey: keyValue.key)
                }
            }
            //self.contextLock.lock()
            /*if !managedContext.insertedObjects.contains(project) {
                managedContext.insert(project)
            }*/
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            //self.contextLock.unlock()
        }
    }
    
    func load(entityName: String, predicate: NSPredicate? = nil/*conditions: [String: Any] = [:]*/) -> [NSManagedObject]? {
        let managedContext = self.persistentContainer.viewContext
          
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        contextLock.lock()
        defer {
            contextLock.unlock()
        }
        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "News")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    init() {
        func deleteAllData(_ entity:String) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else {continue}
                    self.persistentContainer.viewContext.delete(objectData)
                }
            } catch let error {
                print("Detele all data in \(entity) error :", error)
            }
        }
        
        //deleteAllData("LocalCategoryResult")
        //deleteAllData("LocalArticle")
        
    }
}
