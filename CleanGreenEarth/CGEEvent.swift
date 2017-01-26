//
//  CGEEvent.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation

class CGEEvent {
  var id: String?
  var title: String
  var description: String
  var latitude: Double
  var longitude: Double
  var address: String
  var date: Date
  var duration: Int
  
  struct Keys {
    static let id = "id"
    static let title = "title"
    static let description = "description"
    static let location = "location"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let address = "address"
    static let date = "date"
    static let duration = "duration"
  }
  
  init(dictionary: [String:Any]) {
    guard let title = dictionary[Keys.title] as? String,
      let description = dictionary[Keys.description] as? String,
      let latitude = dictionary[Keys.latitude] as? Double,
      let longitude = dictionary[Keys.longitude] as? Double,
      let address = dictionary[Keys.address] as? String,
      let dateString = dictionary[Keys.date] as? String,
      let duration = dictionary[Keys.duration] as? Int else {
        fatalError("Error while initializng CGEEvent with \(dictionary)")
    }
    
    self.id = dictionary[Keys.id] as? String
    self.title = title
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.date = dateString.dateFromISO8601!
    self.duration = duration
  }
}
