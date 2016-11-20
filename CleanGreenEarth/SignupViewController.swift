//
//  SignupViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var retypePasswordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func signup(_ sender: AnyObject) {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text,
      let retypePassword = retypePasswordTextField.text,
      !email.isEmpty, !password.isEmpty, !retypePassword.isEmpty,
      password == retypePassword else {
        return
    }
    
    FIRAuth.auth()?.createUser(withEmail: email, password: password) {
      user, error in
      
      guard user != nil, error == nil else {
        return
      }
      
      self.performSegue(withIdentifier: Constants.Segues.successfulSignup, sender: nil)
    }
  }
}
