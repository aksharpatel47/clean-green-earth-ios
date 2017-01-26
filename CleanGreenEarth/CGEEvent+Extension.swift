//
//  CGEEvent.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import MapKit

extension CGEEvent: MKAnnotation {
  
  public var subtitle: String? {
    return locationName
  }
  
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  var locationName: String {
    return address!.components(separatedBy: ", ").first!
  }
  var locationAddress: String {
    return address!.components(separatedBy: ", ").dropFirst().joined(separator: ", ")
  }
  
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
    static let image = "image"
  }
  
  convenience init(dictionary: [String:Any], context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entity(forEntityName: "CGEEvent", in: context) {
      self.init(entity: entity, insertInto: context)
      guard let title = dictionary[Keys.title] as? String,
        let description = dictionary[Keys.description] as? String,
        let latitude = dictionary[Keys.latitude] as? Double,
        let longitude = dictionary[Keys.longitude] as? Double,
        let address = dictionary[Keys.address] as? String,
        let dateString = dictionary[Keys.date] as? String,
        let id = dictionary[Keys.id] as? String,
        let duration = dictionary[Keys.duration] as? Int else {
          fatalError("Error while initializng CGEEvent with \(dictionary)")
      }
      
      self.id = id
      self.title = title
      self.descriptionText = description
      self.latitude = latitude
      self.longitude = longitude
      self.address = address
      self.date = dateString.dateFromISO8601! as NSDate
      self.duration = Int32(duration)
      self.image = dictionary[Keys.image] as? String
      
      // TODO: Download 
      
    } else {
      fatalError("Error while initializng CGEEvent with \(dictionary)")
    }
  }
  
  func downloadEventImage(completionHandler: ((_ data: Data) -> Void)?) {
    
    guard let imageURLPath = self.image,
      let url = URL(string: imageURLPath) else {
        return
    }
    
    CGEClient.shared.downloadFile(withURL: url) {
      data, error in
      
      guard let data = data, error == nil else {
        return
      }
      
      DispatchQueue.main.async {
        self.imageData = data as NSData
        completionHandler?(data)
      }
    }
  }
  
  static func deleteEvent(withId id: String) {
    let context = CGEDataStack.shared.managedObjectContext
    let fr = NSFetchRequest<CGEEvent>(entityName: "CGEEvent")
    fr.predicate = NSPredicate(format: "id == %@", id)
    
    guard let event = (try? context.fetch(fr))?.first else {
      return
    }
    
    context.delete(event)
  }
}
