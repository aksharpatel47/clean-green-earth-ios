//
//  CGEClient+Authentication.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  func signup(completionHandler: @escaping ((Any?, Error?) -> Void)) {
    postRequest(method: "POST", path: "/account", data: nil, completionHandler: completionHandler)
  }
  
  func updateName(name: String, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    let payload = [
      "name": name
    ]
    
    postRequest(method: "PATCH", path: "/account", data: payload, completionHandler: completionHandler)
  }
}
