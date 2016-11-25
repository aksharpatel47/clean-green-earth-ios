//
//  CGEConstants.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  struct CGEConstants {
    static let host = "localhost"
    static let port = 8080
  }
  
  struct HeaderKeys {
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
  }
  
  struct HeaderValues {
    static let contentTypeJSON = "application/json"
  }
  
  struct UserInfos {
    static let authorization = [NSLocalizedDescriptionKey: "Authorization token expired or invalid."]
  }
  
  struct Paths {
    static let users = "/users"
    static let userSpecific = "/users/{id}"
    static let userSpecificEvents = "/users/{id}/events"
    static let userSpecificAttendance = "/users/{id}/attendance"
    
    static let events = "/events"
    static let eventSpecific = "/events/{id}"
    static let eventSpecificAttendance = "/events/{id}/attendance"
  }
}
