//
//  RoundedButton.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 27/12/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
}
