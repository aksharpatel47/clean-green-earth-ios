//
//  CGEUser+Extension.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import CoreData

extension CGEUser {
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let image = "image"
    static let email = "email"
  }
  
  convenience init(id: String, name: String, image: String?, email: String?, context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entity(forEntityName: "CGEUser", in: context) {
      self.init(entity: entity, insertInto: context)
      self.id = id
      self.name = name
      self.email = email
      self.image = image
    } else {
      fatalError("Error while creating CGEUser Entity")
    }
  }
  
  convenience init(dictionary: [String:String], context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entity(forEntityName: "CGEUser", in: context),
      let id = dictionary[Keys.id],
      let name = dictionary[Keys.name] {
      self.init(entity: entity, insertInto: context)
      self.id = id
      self.name = name
      self.image = dictionary[Keys.image]
      self.email = dictionary[Keys.email]
    } else {
      fatalError("Error while creating CGEUser")
    }
  }
  
  func downloadProfileImage() {
    CGEDataStack.shared.performBackgroundBatchOperation() {
      backgroundContext in
      
      guard let imageURLPath = self.image,
        let url = URL(string: imageURLPath) else {
          return
      }
      
      self.imageData = try? Data(contentsOf: url) as NSData
    }
  }
}
