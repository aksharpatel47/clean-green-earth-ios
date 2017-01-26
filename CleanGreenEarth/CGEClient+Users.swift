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
  
  func getUserDetails(completionHandler: @escaping ((Any?, Error?) -> Void)) {
    request(method: .GET, path: Paths.users, queryString: nil, jsonBody: nil, completionHandler: completionHandler)
  }
  
  func createUser(withName name: String, withImage image: CGEFile?, completionHandler: @escaping((Any?, Error?) -> Void)) {
    
    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
    
    changeRequest?.displayName = name
    
    changeRequest?.commitChanges() {
      error in
      
      guard error == nil else {
        completionHandler(nil, error)
        return
      }
      
      FIRAuth.auth()?.currentUser?.getTokenForcingRefresh(true){
        token, error in
        
        guard error == nil else {
          completionHandler(nil, error)
          return
        }
        
        var images = [CGEFile]()
        
        if let image = image {
          images.append(image)
        }
        
        self.uploadRequest(method: .POST, path: Paths.users, files: images, data: nil, completionHandler: completionHandler)
      }
    }
  }
  
  func saveLoggedInUserAsCurrent() {
    let context = CGEDataStack.shared.managedObjectContext
    
    if let currentFirebaseUser = FIRAuth.auth()?.currentUser {
      UserDefaults.standard.set(true, forKey: Constants.OfflineKeys.successfulSignIn)
      let _ = CGEUser(id: currentFirebaseUser.uid, name: currentFirebaseUser.displayName!, image: nil, email: currentFirebaseUser.email, context: context)
      try? context.save()
    }
  }
}
