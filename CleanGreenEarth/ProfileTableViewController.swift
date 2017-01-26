//
//  ProfileTableViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 24/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileTableViewController: UITableViewController {
  
  // MARK: Properties
  var appDelegate = UIApplication.shared.delegate as! AppDelegate

  // MARK: Outlets
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userNameLabel.text = FIRAuth.auth()?.currentUser?.displayName
    emailLabel.text = FIRAuth.auth()?.currentUser?.email
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)    
  }
  
  // MARK: Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch (indexPath.section, indexPath.row) {
    case (2, 0):
      logOutUser()
    default:
      break
    }
  }
  
  // MARK: Actions
  
  
  // MARK: Helper Functions
  
  func logOutUser() {
    do {
      if let provider = FIRAuth.auth()?.currentUser?.providerData.first?.providerID, provider == "facebook.com" {
        FBSDKLoginManager().logOut()
      }
      
      try FIRAuth.auth()?.signOut()
      UserDefaults.standard.set(false, forKey: Constants.OfflineKeys.successfulSignIn)
      appDelegate.window?.rootViewController = storyboard?.instantiateInitialViewController()
    } catch {
      print("Error while signing the user out. \(error)")
    }
  }
}
