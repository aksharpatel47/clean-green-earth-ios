//
//  CreateUserTableViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit

class CreateUserTableViewController: UITableViewController {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userDisplayNameTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userDisplayNameTextField.delegate = self
    userImageView.image = UIImage()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == 0 && indexPath.row == 0 {
      let alertController = UIAlertController(title: "Get Image From...", message: nil, preferredStyle: .actionSheet)
      
      if UIImagePickerController.isCameraDeviceAvailable(.rear) {
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
          action in
          
          let imagePickerController = UIImagePickerController()
          imagePickerController.sourceType = .camera
          imagePickerController.cameraCaptureMode = .photo
          imagePickerController.allowsEditing = true
          imagePickerController.delegate = self
          
          self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(cameraAction)
      }
      
      let galleryAction = UIAlertAction(title: "Gallery", style: .default) {
        action in
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true, completion: nil)
      }
      
      alertController.addAction(galleryAction)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alertController.addAction(cancelAction)
      
      present(alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func saveUserDetails(_ sender: AnyObject) {
    let name = userDisplayNameTextField.text!
    var profileImage: CGEFile? = nil
    
    if let image = userImageView.image, let data = UIImageJPEGRepresentation(image.resizeTo(maxWidthHeight: 720)!, 0.6) {
      profileImage = CGEFile(name: "user-image", data: data, mimeType: .jpegImage)
    }
    
    prepareForNetworkRequest()
    
    CGEClient.shared.createUser(withName: name, withImage: profileImage) {
      data, error in
      
      self.updateAfterNetworkRequest()
      
      guard error == nil else {
        // TODO: Handle Errors
        return
      }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Constants.Segues.successfulSignup, sender: nil)
      }
    }
  }
}

extension CreateUserTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      DispatchQueue.main.async {
        self.userImageView.image = image
      }
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

extension CreateUserTableViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension CreateUserTableViewController: NetworkRequestProtocol {
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Updating...")
      self.setElements(isEnabled: false)
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
      self.setElements(isEnabled: true)
    }
  }
  
  func setElements(isEnabled enabled: Bool) {
    let imageCellIndexPath = IndexPath(item: 0, section: 0)
    let imageCell = tableView.cellForRow(at: imageCellIndexPath)
    imageCell?.isUserInteractionEnabled = enabled
    self.userDisplayNameTextField.isEnabled = enabled
  }
}
