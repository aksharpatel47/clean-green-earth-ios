//
//  CGEDataStack.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import CoreData

class CGEDataStack {
  
  static let shared = CGEDataStack()
  
  var persistentStoreCoordinator: NSPersistentStoreCoordinator
  var storeURL: URL
  
  var persistenceObjectContext: NSManagedObjectContext
  var managedObjectContext: NSManagedObjectContext
  var backgroundObjectContext: NSManagedObjectContext
  var temporaryObjectContext: NSManagedObjectContext
  
  init() {
    guard let url = Bundle.main.url(forResource: "CGEDataModel", withExtension: "momd") else {
      fatalError("Error while finding Data Model file")
    }
    
    storeURL = url
    
    guard let mom = NSManagedObjectModel(contentsOf: url) else {
      fatalError("Error while creating a Managed Object Model from Data Model")
    }
    
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
    
    persistenceObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    persistenceObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    persistenceObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.parent = persistenceObjectContext
    managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    temporaryObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    temporaryObjectContext.parent = persistenceObjectContext
    
    backgroundObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    backgroundObjectContext.parent = managedObjectContext
    backgroundObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentURL = urls[urls.count - 1]
    let sqliteURL = documentURL.appendingPathComponent("DataModel.sqlite")
    
    do {
      try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                                        at: sqliteURL, options: nil)
    } catch {
      fatalError("Error while adding sqlite store to the persistent store coordinator. \(error)")
    }
  }
}

extension CGEDataStack {
  typealias Batch = (_ workerContext: NSManagedObjectContext) -> Void
  
  func performBackgroundBatchOperation(batch: @escaping Batch) {
    backgroundObjectContext.perform {
      batch(self.backgroundObjectContext)
      
      do {
        try self.backgroundObjectContext.save()
      } catch {
        fatalError("Error while saving in the background context after performing batch operation. \(error)")
      }
    }
  }
}

extension CGEDataStack {
  func saveChanges() {
    
    managedObjectContext.performAndWait {
      
      if self.managedObjectContext.hasChanges {
        do {
          try self.managedObjectContext.save()
        } catch {
          fatalError("Error while saving objects in main context. \(error)")
        }
      }
      
      self.persistenceObjectContext.perform {
        do {
          try self.persistenceObjectContext.save()
        } catch {
          fatalError("Error while saving objects in the persistence context. \(error)")
        }
      }
    }
  }
  
  /// Autosaves the changes after a particular amount of time. This time is specified by the
  /// delay. Delay is measured in seconds.
  func autoSave(on delay: Int) {
    if delay > 0 {
      print("Autosaving")
      saveChanges()
      
      let delayInNanoSeconds = UInt64(delay) * NSEC_PER_SEC
      let time = DispatchTime.now().uptimeNanoseconds + delayInNanoSeconds
      let deadline = DispatchTime(uptimeNanoseconds: time)
      
      DispatchQueue.main.asyncAfter(deadline: deadline) {
        self.autoSave(on: delay)
      }
    }
  }
}
