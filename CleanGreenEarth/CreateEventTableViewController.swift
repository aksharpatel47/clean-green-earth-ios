//
//  CreateEventTableViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 25/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit
import GooglePlaces
import DatePickerDialog

class CreateEventTableViewController: UITableViewController {
  
  // MARK: Properties
  
  var eventLocation: GMSPlace?
  var eventDate: Date?
  let descriptionPlaceHolder = "Enter Event Description Here..."
  var eventDataDictionary: [String:Any] {
    var dictionary = [String:Any]()
    if let eventLocation = eventLocation {
      dictionary[CGEEvent.Keys.longitude] = eventLocation.coordinate.longitude
      dictionary[CGEEvent.Keys.latitude] = eventLocation.coordinate.latitude
      dictionary[CGEEvent.Keys.address] = "\(eventLocation.name), \(eventLocation.formattedAddress!)"
    }
    
    if let eventDate = eventDate {
      dictionary[CGEEvent.Keys.date] = eventDate.iso8601
    }
    
    if let title = titleTextField.text {
      dictionary[CGEEvent.Keys.title] = title
    }
    
    if let description = descriptionTextView.text, descriptionTextView.textColor != UIColor.lightGray {
      dictionary[CGEEvent.Keys.description] = description
    }
    
    dictionary[CGEEvent.Keys.duration] = Int(durationStepper.value)
    
    return dictionary
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var durationStepper: UIStepper!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  // MARK: Actions
  
  @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func savePressed(_ sender: UIBarButtonItem) {
    
    prepareForNetworkRequest()
    
    CGEClient.shared.createEvent(eventDetails: eventDataDictionary, eventImage: eventImageView.image) {
      data, error in
      
      self.updateAfterNetworkRequest()
      
      guard error == nil else {
        
        guard let error = error as? NSError else {
          return
        }
        
        let title = "Event Creation Failed"
        let message = "Error while creating event. Please try again."
        let buttonTitle = "Ok"
        
        if let alert = createAlertController(forError: error) {
          DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
          }
        } else {
          DispatchQueue.main.async {
            self.showBasicAlert(withTitle: title, message: message, buttonTitle: buttonTitle, completionHandler: nil)
          }
        }
        
        return
      }
      
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func stepperPressed(_ sender: UIStepper) {
    let value = Int(sender.value)
    let durationText = value == 1 ? "1 Hour" : "\(value) Hours"
    DispatchQueue.main.async {
      self.durationLabel.text = durationText
    }
  }
  
  // MARK: TableView Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch (indexPath.section, indexPath.row) {
      
    case (0, 0):
      DispatchQueue.main.async {
        self.showAlertControllerToGetImage(inImageView: self.eventImageView, dismissAlertHandler: nil)
      }
      
    case (0, 3):
      let autocompleteController = GMSAutocompleteViewController()
      autocompleteController.delegate = self
      DispatchQueue.main.async {
        self.present(autocompleteController, animated: true, completion: nil)
      }
      
    case (0, 4):
      DatePickerDialog().show(title: "Select Date & Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: Date(), maximumDate: nil, datePickerMode: .dateAndTime) {
        date in
        
        guard let date = date else {
          return
        }
        
        self.eventDate = date
        
        DispatchQueue.main.async {
          self.dateLabel.text = date.stringWithLongDateShortTime()
        }
      }
      
    default:
      break
    }
  }
  
  // MARK: TableView Datasource Methods
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 && indexPath.row == 2 {
      return UITableViewAutomaticDimension
    }
    
    return super.tableView(tableView, heightForRowAt: indexPath)
  }
  
  // MARK: Helper Methods
  
  func setupViews() {
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    
    titleTextField.delegate = self
    
    descriptionTextView.delegate = self
    descriptionTextView.text = descriptionPlaceHolder
    descriptionTextView.textColor = UIColor.lightGray
    
    tableView.tableFooterView = UIView()
  }
}

// MARK: - TextField Delegate Methods

extension CreateEventTableViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - TextView Delegate Methods

extension CreateEventTableViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = descriptionPlaceHolder
      textView.textColor = UIColor.lightGray
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    
    return true
  }
}

// MARK: - GMSAutocomplete Delegate Methods

extension CreateEventTableViewController: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    eventLocation = place
    
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
      self.locationLabel.text = place.name
    }
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("GMSAutoCompleteError: ", error)
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - UIImagePicker Delegate Methods

extension CreateEventTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
    
    guard let image = info[UIImagePickerControllerEditedImage] as? UIImage, let resizedImage = image.resizeTo(maxWidthHeight: 720), let imageData = UIImageJPEGRepresentation(resizedImage, 0.6) else {
      return
    }
    
    DispatchQueue.main.async {
      self.eventImageView.image = UIImage(data: imageData)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension CreateEventTableViewController: NetworkRequestProtocol {
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Creating...")
      self.setControls(isEnabled: false)
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
      self.setControls(isEnabled: false)
    }
  }
  
  func setControls(isEnabled enabled: Bool) {
    tableView.isUserInteractionEnabled = enabled
    navigationItem.leftBarButtonItem?.isEnabled = enabled
    navigationItem.rightBarButtonItem?.isEnabled = enabled
  }
}
