//
//  CommonAlertControllers.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 27/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

func createAlertController(forError error: NSError) -> UIAlertController? {
  
  var title = ""
  var message = ""
  let buttonTitle = "Ok"
  
  if error.domain == NSURLErrorDomain {
    switch error.code {
    case NSURLErrorNotConnectedToInternet:
      title = "No Internet"
      message = "Please connect to the internet and try again."
    case NSURLErrorNetworkConnectionLost:
      title = "Request Error"
      message = "It seems connection to the internet was lost. Please try again."
    default:
      return nil
    }
  }
  
  if error.domain == CGEClient.errorDomain {
    switch error.code {
    case CGEClient.ErrorCode.malformedRequest.rawValue:
      title = "Invalid Request"
      message = "There seems to be either missing or invalid data in your request. Please try again with valid details."
    case CGEClient.ErrorCode.serverError.rawValue:
      title = "Sorry"
      message = "It seems our server is facing problems. Please bear with us while we sort this out."
    case CGEClient.ErrorCode.notFound.rawValue:
      title = "Sorry"
      message = "The request resource is not available."
    default:
      return nil
    }
  }
  
  if error.domain == FIRAuthErrorDomain {
    switch error.code {
    case FIRAuthErrorCode.errorCodeAccountExistsWithDifferentCredential.rawValue:
      title = "Account Exists"
      message = "Your account already exists with us. It was created using a different method of signing in."
    case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
      title = "Account Exists"
      message = "This email is already associated with an existing account. Please login using this email."
    case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
      title = "Email Invalid"
      message = "The email you have entered is invalid. Please enter a valid email and proceed further."
    case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
      title = "Internet Error"
      message = "Error while connecting to the internet. Please make sure the internet is on."
    case FIRAuthErrorCode.errorCodeUserNotFound.rawValue:
      title = "No such user exists"
      message = "Please signup to create an account or signin using Facebook."
    case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
      title = "Invalid Email Password"
      message = "The Email address and the Password don't match. Please verify both and try again."
    default:
      return nil
    }
  }
  
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
  alertController.addAction(okAction)
  return alertController
}
