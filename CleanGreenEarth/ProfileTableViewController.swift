//
//  ProfileTableViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 24/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase

class ProfileTableViewController: UITableViewController {

  // MARK: Outlets
  
  @IBOutlet weak var userNameLabel: UILabel!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userNameLabel.text = FIRAuth.auth()?.currentUser?.displayName
  }
  
  // MARK: Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch (indexPath.section, indexPath.row) {
    case (1, 0):
      printUserToken()
    case (1, 1):
      logOutUser()
    default:
      break
    }
  }
  
  // MARK: Actions
  
  
  // MARK: Helper Functions
  
  func logOutUser() {
    // TODO: Implement
  }
  
  func printUserToken() {
    FIRAuth.auth()?.currentUser?.getTokenWithCompletion({
      token, error in
      
      guard let token = token, error == nil else {
        print("Error while getting the token")
        return
      }
      
      print(token)
    })
  }
}
