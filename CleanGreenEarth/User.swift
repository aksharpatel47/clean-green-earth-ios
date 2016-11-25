//
//  User.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import CoreData

extension User {
  convenience init(uid: String, name: String, context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entity(forEntityName: "User", in: context) {
      self.init(entity: entity, insertInto: context)
      self.uid = uid
      self.name = name
    } else {
      fatalError("Error while creating managed User Object")
    }
  }
}
