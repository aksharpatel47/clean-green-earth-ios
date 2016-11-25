//
//  CGEClient.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import Firebase

final class CGEClient {
  
  static let shared = CGEClient()
  
  let cgeErrorDomain = "CGEErrorDomain"
  
  enum ErrorCode: Int {
    case unknown = 0, noCurrentUser, authenticationFailed, invalidRequest, notFound, invalidJSON
  }
  
  enum HTTPMethods: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
  }
  
  func request(method: HTTPMethods, path: String, queryString: [String:Any]?, jsonBody: [String:Any]?,
                  completionHandler: @escaping ((Any?, Error?) -> Void)) {
    
    createRequest(method: method, path: path, queryString: queryString, jsonBody: jsonBody) {
      request, error in
      
      guard let request = request, error == nil else {
        completionHandler(nil, error)
        return
      }
      
      self.runDataTask(with: request, completionHandler: completionHandler)
    }
  }
}
