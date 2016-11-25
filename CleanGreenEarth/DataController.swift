//
//  DataController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import CoreData

class DataController {
  
  static let shared = DataController()
  
  var persistentContext: NSManagedObjectContext
  var mainContext: NSManagedObjectContext
  var backgroundContext: NSManagedObjectContext
  var psc: NSPersistentStoreCoordinator
  var managedObjectModel: NSManagedObjectModel
  var modelURL: URL
  var persistentStoreURL: URL
  
  init() {
    guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd") else {
      fatalError("Cannot find the Data Model file.")
    }
    
    self.modelURL = modelURL
    
    guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error while creating managed object model.")
    }
    
    self.managedObjectModel = managedObjectModel
    
    psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    persistentContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    persistentContext.persistentStoreCoordinator = psc
    
    mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainContext.parent = persistentContext
    
    backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    backgroundContext.parent = mainContext
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let url = urls[urls.count - 1]
    persistentStoreURL = url.appendingPathComponent("DataModel.sqlite")
    
    do {
      try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                 at: persistentStoreURL, options: nil)
    } catch {
      fatalError("Error while adding sqlite storage to persistent store coordinator. \(error)")
    }
  }
}

extension DataController {
  typealias Batch = (_ workerContext: NSManagedObjectContext) -> Void
  
  func performBackgroundOperation(batch: @escaping Batch) {
    backgroundContext.perform {
      batch(self.backgroundContext)
      
      do {
        try self.backgroundContext.save()
      } catch {
        fatalError("Error while trying to save on background thread. \(error)")
      }
    }
  }
}

extension DataController {
  func save() {
    
    self.mainContext.performAndWait {
      if self.mainContext.hasChanges {
        do {
          try self.mainContext.save()
        } catch {
          fatalError("Error while saving on the main thread. \(error)")
        }
        
        self.persistentContext.perform {
          if self.persistentContext.hasChanges {
            do {
              try self.persistentContext.save()
            } catch {
              fatalError("Error while saving on the persistent thread. \(error)")
            }
          }
        }
      }
    }
  }
  
  func autoSave(after delay: Int) {
    if delay > 0 {
      print("Autosaving")
      save()
      
      let delayInNanoSeconds = DispatchTime.now().uptimeNanoseconds + UInt64(delay) * NSEC_PER_SEC
      let time = DispatchTime(uptimeNanoseconds: delayInNanoSeconds)
      
      DispatchQueue.main.asyncAfter(deadline: time) {
        self.autoSave(after: delay)
      }
    }
  }
}
