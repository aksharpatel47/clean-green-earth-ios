//
//  ImageExtensions.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  func resizeTo(maxWidthHeight: CGFloat) -> UIImage? {
    let currentSize = self.size
    
    let ratio: CGFloat
    let newSize: CGSize
    
    if currentSize.height > currentSize.width {
      ratio = currentSize.height / currentSize.width
      let height = min(maxWidthHeight, currentSize.height)
      let width = height / ratio
      newSize = CGSize(width: width, height: height)
    } else {
      ratio = currentSize.width / currentSize.height
      let width = min(maxWidthHeight, currentSize.width)
      let height = width / ratio
      newSize = CGSize(width: width, height: height)
    }
    
    UIGraphicsBeginImageContext(newSize)
    self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}
