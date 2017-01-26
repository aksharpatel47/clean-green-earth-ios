//
//  ImageViewExtensions.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 25/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func showAlertControllerToGetImage(inImageView imageView: UIImageView,
                                     dismissAlertHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: "Get Image From...", message: nil, preferredStyle: .actionSheet)
    
    let selectPhotoAction = UIAlertAction(title: "Gallery", style: .default) {
      action in
      
      let imagePickerController = UIImagePickerController()
      imagePickerController.sourceType = .photoLibrary
      imagePickerController.allowsEditing = true
      
      if let vc = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        imagePickerController.delegate = vc
      }
      
      DispatchQueue.main.async {
        self.present(imagePickerController, animated: true, completion: nil)
      }
    }
    
    alertController.addAction(selectPhotoAction)
    
    if UIImagePickerController.isCameraDeviceAvailable(.rear) {
      let capturePhotoAction = UIAlertAction(title: "Camera", style: .default) {
        action in
        
        let captureImageController = UIImagePickerController()
        captureImageController.sourceType = .camera
        captureImageController.cameraCaptureMode = .photo
        captureImageController.allowsEditing = true
        
        if let vc = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
          captureImageController.delegate = vc
        }
        
        DispatchQueue.main.async {
          self.present(captureImageController, animated: true, completion: nil)
        }
      }
      
      alertController.addAction(capturePhotoAction)
    }
    
    if let image = imageView.image, image.size != CGSize(width: 0, height: 0) {
      let removePhotoAction = UIAlertAction(title: "Remove Photo", style: .default) {
        action in
        
        DispatchQueue.main.async {
          imageView.image = UIImage()
        }
      }
      
      alertController.addAction(removePhotoAction)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: dismissAlertHandler)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
}
