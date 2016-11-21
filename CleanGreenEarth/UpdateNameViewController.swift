//
//  UpdateNameViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase

class UpdateNameViewController: UITableViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func updateName(_ sender: AnyObject) {
    guard let name = nameTextField.text,
      !name.isEmpty else {
        return
    }
    
    guard let user = FIRAuth.auth()?.currentUser else {
      return
    }
    
    let changeRequest = user.profileChangeRequest()
    changeRequest.displayName = name
    
    changeRequest.commitChanges(completion: {
      error in
      
      guard error == nil else {
        return
      }
      
      CGEClient.shared.updateName(name: name) {
        data, error in
        
        guard let data = data, error == nil else {
          return
        }
        
        print(data)
        
        DispatchQueue.main.async {
          self.performSegue(withIdentifier: Constants.Segues.successfulSignup, sender: nil)
        }
      }
    })
  }
}
