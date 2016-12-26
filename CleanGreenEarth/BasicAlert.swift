//
//  BasicAlert.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/12/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func showBasicAlert(withTitle title: String?, message: String?, buttonTitle: String?, completionHandler: ((UIAlertAction) -> Void)? ) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okButton = UIAlertAction(title: buttonTitle, style: .default, handler: completionHandler)
    alertController.addAction(okButton)
    
    present(alertController, animated: true, completion: nil)
  }
}
