//
//  CGEClient+Authentication.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  func signup(withName name: String, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    let body = ["name": name]
    request(method: .POST, path: Paths.users, queryString: nil, jsonBody: body, completionHandler: completionHandler)
  }
}
