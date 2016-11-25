//
//  Event.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Event: MKAnnotation {
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  convenience init(id: String, title: String, description: String,
                   coordinate: CLLocationCoordinate2D, address: String,
                   date: Date, duration: Int32, owner: User, temp: Bool, context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entity(forEntityName: "Event", in: context) {
      self.init(entity: entity, insertInto: temp ? nil : context)
      self.id = id
      self.title = title
      self.eventDescription = description
      self.latitude = coordinate.latitude
      self.longitude = coordinate.longitude
      self.address = address
      self.date = date as NSDate
      self.duration = duration
      self.owner = owner
    } else {
      fatalError("Error while creating Event")
    }
  }
}
