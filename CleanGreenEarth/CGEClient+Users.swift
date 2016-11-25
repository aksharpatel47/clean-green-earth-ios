//
//  CGEClient+Users.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  func updateName(name: String, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    let payload = [
      "name": name
    ]
    
    request(method: .PATCH, path: Paths.users, queryString: nil, jsonBody: payload, completionHandler: completionHandler)
  }
  
  func getUserEvents(userId: String, completionHandler: @escaping (Any?, Error?) -> Void) {
    
  }
  
  func getUserAttendingEvents(userId: String, completionHandler: @escaping (Any?, Error?) -> Void) {
    
  }
}
