//
//  LocalStorageManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import CoreData

struct PrimaryKey {
    var key: String
    var value: CVarArg
}

class LocalStorageManager {
    var entitiesEntryLimits: [String: Int] = [
        CoreDataEntities.localArticle: 200,
        CoreDataEntities.localImage: 20,
        CoreDataEntities.localCategoryResult: 20,
    ]
    
    var contextLock = NSLock()
    
    func drop(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        let managedContext = self.persistentContainer.viewContext
        
        let _ = try? managedContext.execute(request)
    }
    
    func eraseToLimits(entityName: String) {
        DispatchQueue.main.async {
            let managedContext = self.persistentContainer.viewContext
            if let entities = self.load(entityName: entityName) {
                var shouldDelete = 0
                
                if let limit = self.entitiesEntryLimits[entityName] {
                    shouldDelete = entities.count - limit
                }
                
                if shouldDelete > 0 {
                    //TODO: add custom logic for various objects (e.g. delete news only based on their publishedAt value)
                    let oldestToDelete = entities
                        .sorted(by: { ($0.value(forKey: "lastAccess") as? Date ?? Date()) > ($1.value(forKey: "lastAccess") as? Date ?? Date()) })
                        .dropLast(shouldDelete)
                    self.contextLock.lock()
                    oldestToDelete.forEach({
                        managedContext.delete($0)
                    })
                    self.contextLock.unlock()
                }
            }
        }
    }
    
    ///Primary key constraint immitation
    func primaryKeyDeleteTrigger(entityName: String, primaryKey: PrimaryKey) {
        let managedContext = self.persistentContainer.viewContext
        if let loaded = Current.localStorage.load(entityName: entityName, predicate: .init(format: "\(primaryKey.key) == %@", primaryKey.value)) {
            loaded.forEach {
                managedContext.delete($0)
            }
        }
    }
    
    func save(entityFields: [String: Any?], to entityName: String, primaryKey: PrimaryKey? = nil) {
        
        DispatchQueue.main.async {
            if let primaryKey = primaryKey {
                self.primaryKeyDeleteTrigger(entityName: entityName, primaryKey: primaryKey)
            }
            
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
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func load(entityName: String, predicate: NSPredicate? = nil) -> [NSManagedObject]? {
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
        let container = NSPersistentContainer(name: "News")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
