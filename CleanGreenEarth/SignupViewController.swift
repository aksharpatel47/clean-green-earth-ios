//
//  SignupViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UITableViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var signupButton: RoundedButton!
  
  // MARK: Functions
  
  func setControls(isEnabled enabled: Bool) {
    signupButton.isEnabled = enabled
    emailTextField.isEnabled = enabled
    passwordTextField.isEnabled = enabled
  }
  
  // MARK: Actions
  
  @IBAction func signup(_ sender: AnyObject) {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text,
      !email.isEmpty, !password.isEmpty else {
        DispatchQueue.main.async {
          self.showBasicAlert(withTitle: "Inputs Missing", message: "Please enter all the inputs to Sign up.", buttonTitle: "Ok", completionHandler: nil)
        }
        
        return
    }
    
    prepareForNetworkRequest()
    
    CGEClient.shared.signUp(withEmail: email, password: password) {
      user, error in
      
      self.updateAfterNetworkRequest()
      
      guard error == nil else {        
        if let error = error as? NSError {
          
          let alertTitle = "Sign Up Failed"
          let alertMessage = "Failed to create the user. Please check the inputs and try again."
          let alertButtonText = "Ok"
          
          if let alertController = createAlertController(forError: error) {
            DispatchQueue.main.async {
              self.present(alertController, animated: true, completion: nil)
            }
          } else {
            DispatchQueue.main.async {
              self.showBasicAlert(withTitle: alertTitle, message: alertMessage, buttonTitle: alertButtonText, completionHandler: nil)
            }
          }
        }
        
        return
      }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Constants.Segues.createUserOnServer, sender: nil)
      }
    }
  }
}

extension SignupViewController: NetworkRequestProtocol {
  /// All operations that must be executed before a network request starts. Runs on the main thread.
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Signing Up...")
      self.setControls(isEnabled: false)
    }
  }
  
  /// All operations that must be executed after a network request completes. Runs on the main thread.
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
      self.setControls(isEnabled: true)
    }
  }
}
