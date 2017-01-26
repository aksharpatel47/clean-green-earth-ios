//
//  CGEClient+Events.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import FirebaseAuth

extension CGEClient {
  func createEvent(eventDetails: [String:Any], eventImage: UIImage?, completionHandler: @escaping (Any?, Error?) -> Void) {
    
    if let image = eventImage, let imageData = UIImageJPEGRepresentation(image, 1.0) {
      let file = CGEFile(name: "event-image", data: imageData, mimeType: .jpegImage)
      uploadRequest(method: .POST, path: Paths.events, files: [file], data: eventDetails, completionHandler: completionHandler)
    } else {
      request(method: .POST, path: Paths.events, queryString: nil, jsonBody: eventDetails, completionHandler: completionHandler)
    }
  }
  
  func getEvents(completionHandler: @escaping (Error?) -> Void) {
    request(method: .GET, path: Paths.userEvents, queryString: nil, jsonBody: nil) {
      response, error in
      
      guard let response = response as? [String:Any],
        let data = response[CGEClient.ResponseKeys.data] as? [String:Any],
        let events = data[CGEClient.ResponseKeys.events] as? [[String:Any]] else {
          completionHandler(error)
          return
      }
            
      CGEDataStack.shared.performBackgroundBatchOperation() {
        context in
        let userFR = NSFetchRequest<CGEUser>(entityName: "CGEUser")
        userFR.predicate = NSPredicate(format: "id == %@", FIRAuth.auth()!.currentUser!.uid)
        let currentUser = (try! context.fetch(userFR)).first!
        
        for event in events {
          let event = CGEEvent(dictionary: event, context: context)
          event.owner = currentUser
        }
      }
    }
  }
  
  func getEventsAround(coordinate: CLLocationCoordinate2D, completionHandler: @escaping([CGEEvent]?, Error?) -> Void) {
    let queryItems = ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
    request(method: .GET, path: Paths.events, queryString: queryItems, jsonBody: nil) {
      response, error in
      
      guard let response = response as? [String:Any],
        let data = response[CGEClient.ResponseKeys.data] as? [String:Any],
        let events = data[CGEClient.ResponseKeys.events] as? [[String:Any]] else {
          // TODO: Handle Error
          completionHandler(nil, error)
          return
      }
      
      let context = CGEDataStack.shared.backgroundObjectContext
      
      for event in events {
        let _ = CGEEvent(dictionary: event, context: context)
      }
      
      try? context.save()
    }
  }
}
