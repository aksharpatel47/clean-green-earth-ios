//
//  CGEClient+Authentication.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import FirebaseAuth

extension CGEClient {
  func signUp(withEmail email: String, password: String, completionHandler: @escaping ((FIRUser?, Error?) -> Void)) {
    
    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: completionHandler)
  }
  
  /*
   * This method first signs in to firebase via email and password. It then goes on
   * to check if the user exists on the server and sends that status through the
   * completionHandler.
   */
  func signIn(withEmail email: String, password: String, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    FIRAuth.auth()?.signIn(withEmail: email, password: password) {
      user, error in
      
      guard error == nil else {
        completionHandler(nil, error)
        return
      }
      
      self.getUserDetails(completionHandler: completionHandler)
    }
  }
  
  /*
   * This method creates a facebook credential and signs in to firebase using that credential.
   * Then it checks if the user exists on the server and sends that status through the
   * completionHandler.
   */
  func signIn(withFacebookToken token: String, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    
    let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: token)
    
    FIRAuth.auth()?.signIn(with: fbCredentials) {
      user, error in
      
      guard error == nil else {
        completionHandler(nil, error)
        return
      }
      
      self.getUserDetails(completionHandler: completionHandler)
    }
  }
}
