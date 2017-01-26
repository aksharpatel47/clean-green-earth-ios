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
  
  func getEvents(forUser user: CGEUser, completionHandler: @escaping (Error?) -> Void) {
    request(method: .GET, path: Paths.userEvents, queryString: nil, jsonBody: nil) {
      response, error in
      
      guard let response = response as? [String:Any],
        let data = response[CGEClient.ResponseKeys.data] as? [String:Any],
        let createdEvents = data[CGEClient.ResponseKeys.createdEvents] as? [[String:Any]],
        let attendingEvents = data[CGEClient.ResponseKeys.attendingEvents] as? [[String:Any]] else {
          completionHandler(error)
          return
      }
      
      let objectId = user.objectID
      
      CGEDataStack.shared.performBackgroundBatchOperation() {
        context in
        let currentUser = context.object(with: objectId) as! CGEUser
        
        for createdEvent in createdEvents {
          let event = CGEEvent(dictionary: createdEvent, context: context)
          event.owner = currentUser
        }
        
        for attEvent in attendingEvents {
          let event = CGEEvent(dictionary: attEvent, context: context)
          event.addToAttendees(currentUser)
        }
      }
      
      completionHandler(nil)
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
      
      DispatchQueue.main.async {
        let context = CGEDataStack.shared.temporaryObjectContext
        
        var cgeEvents = [CGEEvent]()
        
        for event in events {
          cgeEvents.append(CGEEvent(dictionary: event, context: context))
        }
        
        completionHandler(cgeEvents, nil)
      }
    }
  }
}
