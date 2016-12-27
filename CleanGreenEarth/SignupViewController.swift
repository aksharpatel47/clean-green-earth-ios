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
  
  // MARK: Outlets
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var retypePasswordTextField: UITextField!
  
  // MARK: Functions
  
  func setTextFields(isEnabled enabled: Bool) {
    nameTextField.isEnabled = enabled
    emailTextField.isEnabled = enabled
    passwordTextField.isEnabled = enabled
    retypePasswordTextField.isEnabled = enabled
  }
  
  // MARK: Actions
  
  @IBAction func signup(_ sender: AnyObject) {
    
    guard let name = nameTextField.text,
      let email = emailTextField.text,
      let password = passwordTextField.text,
      let retypePassword = retypePasswordTextField.text,
      !email.isEmpty, !password.isEmpty, !retypePassword.isEmpty,
      password == retypePassword else {
        
        DispatchQueue.main.async {
          self.showBasicAlert(withTitle: "Inputs Missing", message: "Please enter all the inputs to Sign up.", buttonTitle: "Ok", completionHandler: nil)
        }
        
        return
    }
    
    prepareForNetworkRequest()
    
    FIRAuth.auth()?.createUser(withEmail: email, password: password) {
      user, error in
      
      guard let _ = user, error == nil else {
        
        self.updateAfterNetworkRequest()
        
        if let error = error as? NSError, error.domain == FIRAuthErrorDomain {
          
          if error.code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
            
          } else if error.code == FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue {
            
          } else {
            
          }
        }
        
        return
      }
      
      let request = FIRAuth.auth()?.currentUser?.profileChangeRequest()
      request?.displayName = name
      request?.commitChanges() {
        requestError in
        
        if let requestError = requestError as? NSError, requestError.domain == FIRAuthErrorDomain {
          
          self.updateAfterNetworkRequest()
          
          if requestError.code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
            
          } else {
            
          }
        } else {
          
          CGEClient.shared.signup(withName: name) {
            user, error in
            
            self.updateAfterNetworkRequest()
            
            guard error == nil else {
              return
            }
            
            DispatchQueue.main.async {
              self.performSegue(withIdentifier: Constants.Segues.successfulSignup, sender: nil)
            }
          }
        }
      }
    }
  }
}

extension SignupViewController: NetworkRequestProtocol {
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.activityIndicator.startAnimating()
      self.setTextFields(isEnabled: false)
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
      self.setTextFields(isEnabled: true)
    }
  }
}
