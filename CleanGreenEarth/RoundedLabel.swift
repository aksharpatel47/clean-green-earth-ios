//
//  RoundedLabel.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/12/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedLabel: UILabel {
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable var leftPadding: CGFloat = 0.0
  @IBInspectable var rightPadding: CGFloat = 0.0
  @IBInspectable var topPadding: CGFloat = 0.0
  @IBInspectable var bottomPadding: CGFloat = 0.0
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }
  
  override var intrinsicContentSize: CGSize {
    let initialSize = super.intrinsicContentSize
    return CGSize(width: initialSize.width + self.leftPadding + self.rightPadding, height: initialSize.height + self.topPadding + self.bottomPadding)
  }
}
