//
//  CGEClient+Events.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import MapKit

extension CGEClient {
  func createEvent(eventDetails: [String:Any], eventImage: UIImage?, completionHandler: @escaping (Any?, Error?) -> Void) {
    
    if let image = eventImage, let imageData = UIImageJPEGRepresentation(image, 1.0) {
      let file = CGEFile(name: "event-image", data: imageData, mimeType: .jpegImage)
      uploadRequest(method: .POST, path: Paths.events, files: [file], data: eventDetails, completionHandler: completionHandler)
    } else {
      request(method: .POST, path: Paths.events, queryString: nil, jsonBody: eventDetails, completionHandler: completionHandler)
    }
  }
  
  func getEvents(completionHandler: @escaping ([CGEEvent]?, Error?) -> Void) {
    request(method: .GET, path: Paths.userEvents, queryString: nil, jsonBody: nil) {
      response, error in
      
      print(response)
      
      guard let response = response as? [String:Any],
        let data = response["data"] as? [String:Any],
        let events = data["events"] as? [[String:Any]] else {
          completionHandler(nil, error)
          return
      }
      
      var cgeEvents = [CGEEvent]()
      
      for event in events {
        let cgeEvent = CGEEvent(dictionary: event)
        cgeEvents.append(cgeEvent)
      }
      
      completionHandler(cgeEvents, nil)
    }
  }
//
//  func updateEvent(event: Event, completionHandler: @escaping (Any?, Error?) -> Void) {
//    
//  }
//  
//  func deleteEvent(eventId: Event, completionHandler: @escaping (Any?, Error?) -> Void) {
//    
//  }
//  
//  func searchForEvents(around coordinate: CLLocationCoordinate2D, completionHandler: @escaping ([Event]?, Error?) -> Void) {
//    
//  }
}
