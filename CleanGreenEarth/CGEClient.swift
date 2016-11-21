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
  
  func postRequest(method: String, path: String, data: [String:Any]?, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    guard let url = constructURL(path: path, queryString: nil) else {
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    FIRAuth.auth()?.currentUser?.getTokenWithCompletion() {
      token, error in
      
      guard let token = token, error == nil else {
        return
      }
      
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authentication")
      
      if let data = data {
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      
      let task = URLSession.shared.dataTask(with: request, completionHandler: {
        data, response, error in
        
        guard let data = data, error == nil,
          let dataDictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            
            completionHandler(nil, error)
            
            return
        }
        
        completionHandler(dataDictionary, nil)
        
      })
      
      task.resume()
    }
    
  }
}
