//
//  CGEHelpers.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  func constructURL(path: String, queryString: [String:Any]?) -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = CGEConstants.host
    urlComponents.port = CGEConstants.port
    urlComponents.path = path
    urlComponents.queryItems = []
    
    if let queryString = queryString {
      for (key, value) in queryString {
        urlComponents.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
      }
    }
    
    return urlComponents.url
  }
}
