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

class LoginViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loginViewsStackView: UIStackView!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let fbLoginButton = FBSDKLoginButton()
    fbLoginButton.delegate = self
    loginViewsStackView.addArrangedSubview(fbLoginButton)
    let constraint = NSLayoutConstraint(item: fbLoginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 45)
    fbLoginButton.addConstraint(constraint)
  }
  
  // MARK: Helper Functions
  
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
    
    FIRAuth.auth()?.signIn(withEmail: email, password: password) {
      user, error in
      
      self.updateAfterNetworkRequest()
      
      guard user != nil, error == nil else {
        
        if let error = error as? NSError, error.domain == FIRAuthErrorDomain {
          
          var alertTitle = "Cannot Login"
          var alertMessage = "Please check your Email adress and Password."
          let alertButtonTitle = "Ok"
          
          if error.code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
            alertTitle = "No Internet"
            alertMessage = "Please connect to the Internet."
          } else if error.code == FIRAuthErrorCode.errorCodeUserNotFound.rawValue {
            alertTitle = "User Not Found"
            alertMessage = "Please create a new User with this Email address."
          }
          
          DispatchQueue.main.async {
            self.showBasicAlert(withTitle: alertTitle, message: alertMessage, buttonTitle: alertButtonTitle, completionHandler: nil)
          }
        }
        
        return
      }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Constants.Segues.successfulLogin, sender: nil)
      }
    }
  }
  
  @IBAction func signup(_ sender: AnyObject) {
    performSegue(withIdentifier: Constants.Segues.signup, sender: nil)
  }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
    return true
  }
  
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
  }
}
