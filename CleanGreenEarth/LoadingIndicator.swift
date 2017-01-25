//
//  LoadingIndicator.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func showLoadingIndicator(withText text: String) {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 14, height: 44)
    
    let loadingLabel = UILabel(frame: CGRect(x: 22, y: 0, width: 50, height: 44))
    loadingLabel.text = text
    loadingLabel.textColor = UIColor.white
    loadingLabel.sizeToFit()
    loadingLabel.frame = CGRect(x: 22, y: 0, width: loadingLabel.frame.width, height: 44)
    
    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 14 + loadingLabel.frame.width + 8, height: 44))
    titleView.addSubview(activityIndicator)
    titleView.addSubview(loadingLabel)
    
    activityIndicator.startAnimating()
    
    self.navigationItem.titleView = titleView
  }
  
  func hideLoadingIndicator() {
    self.navigationItem.titleView = nil
  }
}
