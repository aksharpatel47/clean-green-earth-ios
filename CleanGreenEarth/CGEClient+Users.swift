//
//  CGEClient+Users.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import FirebaseAuth

extension CGEClient {
  func signUp(withEmail email: String, password: String, name: String, completionHandler: @escaping ((FIRUser?, Error?) -> Void)) {
    
    let payload = ["email": email, "password": password, "name": name]
    request(method: .POST, path: Paths.users, queryString: nil, jsonBody: payload) {
      data, error in
      
      guard error == nil else {
        completionHandler(nil, error)
        return
      }
      
      FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: completionHandler)
    }
  }
  
  func signIn(withEmail email: String, password: String, completionHandler: @escaping ((FIRUser?, Error?) -> Void)) {
    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: completionHandler)
  }
  
  func signIn(withFacebookToken token: String, completionHandler: @escaping ((FIRUser?, Error?) -> Void)) {
    
    let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: token)
    
    FIRAuth.auth()?.signIn(with: fbCredentials) {
      user, error in
      
      guard let user = user,
        let name = user.displayName,
        let photoURL = user.photoURL,
        error == nil else {
        completionHandler(nil, error)
        return
      }
      
      let payload = ["name": name, "imageURL": photoURL.absoluteString]
      
      self.request(method: .POST, path: Paths.users, queryString: nil, jsonBody: payload) {
        data, error in
        
        guard error == nil else {
          completionHandler(nil, error)
          return
        }
        
        completionHandler(user, nil)
      }
    }
  }
  
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
