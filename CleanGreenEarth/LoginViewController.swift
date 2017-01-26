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
  @IBOutlet weak var loginButton: RoundedButton!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    facebookLoginButton.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  // MARK: Helper Functions
  
  func prepareForNetworkRequest() {
    self.showLoadingIndicator(withText: "Logging In...")
    self.setControls(isEnabled: false)
  }
  
  func updateAfterNetworkRequest() {
    self.hideLoadingIndicator()
    self.setControls(isEnabled: true)
  }
  
  func setControls(isEnabled enabled: Bool) {
    self.loginButton.isEnabled = enabled
    self.facebookLoginButton.isEnabled = enabled
    self.emailTextField.isEnabled = enabled
    self.passwordTextField.isEnabled = enabled
  }
  
  // MARK: Actions
  
  func handleLoginError(error: Error?) {
    
    guard let error = error as? NSError else {
      return
    }
    
    if error.domain == CGEClient.errorDomain && error.code == CGEClient.ErrorCode.notFound.rawValue {
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Constants.Segues.signupIncomplete, sender: nil)
      }
    } else if let alertController = createAlertController(forError: error) {
      DispatchQueue.main.async {
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func login(_ sender: AnyObject) {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text,
      !email.isEmpty, !password.isEmpty else {
        DispatchQueue.main.async {
          self.showBasicAlert(withTitle: "Missing Inputs", message: "Please enter both Email and Password to Login.", buttonTitle: "Ok", completionHandler: nil)
        }
        
        return
    }
    
    DispatchQueue.main.async {
      self.prepareForNetworkRequest()
    }
    
    CGEClient.shared.signIn(withEmail: email, password: password) {
      data, error in
      
      DispatchQueue.main.async {
        self.updateAfterNetworkRequest()
      }
      
      guard error == nil else {
        self.handleLoginError(error: error)
        return
      }
      
      DispatchQueue.main.async {
        CGEClient.shared.saveLoggedInUserAsCurrent()
        self.performSegue(withIdentifier: Constants.Segues.successfulLogin, sender: nil)
      }
    }
  }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    
    guard let result = result, let token = result.token, let tokenString = token.tokenString, error == nil else {
      DispatchQueue.main.async {
        self.updateAfterNetworkRequest()
      }
      return
    }
    
    CGEClient.shared.signIn(withFacebookToken: tokenString) {
      data, error in
      
      DispatchQueue.main.async {
        self.updateAfterNetworkRequest()
      }
      
      guard error == nil else {
        self.handleLoginError(error: error)
        return
      }
      
      DispatchQueue.main.async {
        CGEClient.shared.saveLoggedInUserAsCurrent()
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
