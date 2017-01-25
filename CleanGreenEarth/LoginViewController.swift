//
//  LoginViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 19/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UITableViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    facebookLoginButton.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  // MARK: Helper Functions
  
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Logging In...")
      self.setTextFields(isEnabled: false)
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
      self.setTextFields(isEnabled: true)
    }
  }
  
  func setTextFields(isEnabled enabled: Bool) {
    self.emailTextField.isEnabled = enabled
    self.passwordTextField.isEnabled = enabled
  }
  
  // MARK: Actions
  
  @IBAction func login(_ sender: AnyObject) {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text,
      !email.isEmpty, !password.isEmpty else {
        DispatchQueue.main.async {
          self.showBasicAlert(withTitle: "Missing Inputs", message: "Please enter both Email and Password to Login.", buttonTitle: "Ok", completionHandler: nil)
        }
        
        return
    }
    
    prepareForNetworkRequest()
    
    CGEClient.shared.signIn(withEmail: email, password: password) {
      data, error in
      
      self.updateAfterNetworkRequest()
      
      guard error == nil else {
        
        guard let error = error as? NSError else {
          return
        }
        
        switch (error.domain, error.code) {
        case (CGEClient.errorDomain, CGEClient.ErrorCode.notFound.rawValue):
          
          DispatchQueue.main.async {
            self.performSegue(withIdentifier: Constants.Segues.signupIncomplete, sender: nil)
          }
          
          break
        default:
          break
        }
        
        return
      }
      
      DispatchQueue.main.async {
        UserDefaults.standard.set(true, forKey: Constants.OfflineKeys.successfulSignIn)
        self.performSegue(withIdentifier: Constants.Segues.successfulLogin, sender: nil)
      }
    }
  }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    
    DispatchQueue.main.async {
      self.updateAfterNetworkRequest()
    }
    
    guard error == nil else {
      return
    }
    
    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    
    FIRAuth.auth()?.signIn(with: credential) {
      user, error in
      
      guard user != nil, error == nil else {
        return
      }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Constants.Segues.successfulLogin, sender: nil)
      }
    }
  }
  
  func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
    DispatchQueue.main.async {
      self.prepareForNetworkRequest()
    }
    
    return true
  }
  
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
  }
}

// MARK: - Text Field Delegates

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
