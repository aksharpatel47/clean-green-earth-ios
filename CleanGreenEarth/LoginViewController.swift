//
//  LoginViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 19/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  @IBAction func login(_ sender: AnyObject) {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text,
      !email.isEmpty, !password.isEmpty else {
        return
    }
    
    FIRAuth.auth()?.signIn(withEmail: email, password: password) {
      user, error in
      
      guard user != nil, error == nil else {
        return
      }
      
      self.performSegue(withIdentifier: Constants.Segues.successfulLogin, sender: nil)
    }
  }
  
  @IBAction func signup(_ sender: AnyObject) {
    performSegue(withIdentifier: Constants.Segues.signup, sender: nil)
  }
}

