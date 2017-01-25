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
  
  // MARK: Properties
  var appDelegate = UIApplication.shared.delegate as! AppDelegate

  // MARK: Outlets
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var verificationStatusLabel: UILabel!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userNameLabel.text = FIRAuth.auth()?.currentUser?.displayName
    emailLabel.text = FIRAuth.auth()?.currentUser?.email
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let emailVerificationStatus = FIRAuth.auth()?.currentUser?.isEmailVerified {
      self.verificationStatusLabel.text = emailVerificationStatus ? "Verified" : "Unverified"
      self.verificationStatusLabel.backgroundColor = emailVerificationStatus ? UIColor.darkGray : UIColor.red
    }
    
    FIRAuth.auth()?.currentUser?.reload() {
      completion in
      
      if let emailVerificationStatus = FIRAuth.auth()?.currentUser?.isEmailVerified {
        self.verificationStatusLabel.text = emailVerificationStatus ? "Verified" : "Unverified"
        self.verificationStatusLabel.backgroundColor = emailVerificationStatus ? UIColor.darkGray : UIColor.red
      }
    }
  }
  
  // MARK: Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch (indexPath.section, indexPath.row) {
    case (1, 0):
      sendVerificationEmail()
    case (2, 0):
      printUserToken()
    case (2, 1):
      logOutUser()
    default:
      break
    }
  }
  
  // MARK: Actions
  
  
  // MARK: Helper Functions
  
  func logOutUser() {
    do {
      try FIRAuth.auth()?.signOut()
      UserDefaults.standard.set(false, forKey: Constants.OfflineKeys.successfulSignIn)
      appDelegate.window?.rootViewController = storyboard?.instantiateInitialViewController()
    } catch {
      print("Error while signing the user out. \(error)")
    }
  }
  
  func sendVerificationEmail() {
    if let emailVerificationStatus = FIRAuth.auth()?.currentUser?.isEmailVerified,
      emailVerificationStatus == false {
      FIRAuth.auth()?.currentUser?.sendEmailVerification() {
        error in
        
        guard error == nil else {
          return
        }
        
        print("Verification Email Sent.")
      }
    }
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
