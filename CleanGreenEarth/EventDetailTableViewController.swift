//
//  EventDetailTableViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit
import Foundation

class EventDetailTableViewController: UITableViewController {
  
  // MARK: Properties
  /// (segue!) Event Detail Information
  var cgeEvent: CGEEvent!
  
  // MARK: Outlets
  
  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var eventDescriptionLabel: UILabel!
  @IBOutlet weak var eventLocationLabel: UILabel!
  @IBOutlet weak var eventDateLabel: UILabel!
  @IBOutlet weak var eventDurationLabel: UILabel!
  @IBOutlet weak var eventAttendanceSwitch: UISwitch!
  @IBOutlet weak var eventRSVPLabel: UILabel!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    
    CGEDataStack.shared.saveChanges()
    
    if let user = CGEUser.getUser(withId: nil) {
      if let ownEvents = user.createdEvents as? Set<CGEEvent> {
        if ownEvents.map({ $0.id }).contains(where: { $0 == cgeEvent.id! }) {
          eventAttendanceSwitch.setOn(true, animated: true)
          eventAttendanceSwitch.isEnabled = false
          eventRSVPLabel.text = "Attending"
        }
      }
      
      if let attendingEvents = user.attending as? Set<CGEEvent> {
        if attendingEvents.map({ $0.id }).contains(where: { $0 == cgeEvent.id }) {
          eventAttendanceSwitch.setOn(true, animated: true)
          eventRSVPLabel.text = "Attending"
        }
      }
    }
  }
  
  // MARK: Actions
  
  @IBAction func rsvpChanged(_ sender: UISwitch) {
    let previousState = !sender.isOn
    
    if sender.isOn {
      CGEClient.shared.attendEvent(withId: cgeEvent.id!) {
        data, error in
        
        guard error == nil else {
          
          DispatchQueue.main.async {
            self.eventAttendanceSwitch.setOn(previousState, animated: true)
          }
          
          self.handleNetworkError(error: error)
          
          return
        }
        
        DispatchQueue.main.async {
          self.eventRSVPLabel.text = "Attending"
        }
      }
    } else {
      CGEClient.shared.removeAttendanceFromEvent(withId: cgeEvent.id!) {
        data, error in
        
        guard error == nil else {
          
          DispatchQueue.main.async {
            self.eventAttendanceSwitch.setOn(previousState, animated: true)
          }
          
          self.handleNetworkError(error: error)
          
          return
        }
        
        DispatchQueue.main.async {
          CGEEvent.deleteEvent(withId: self.cgeEvent.id!)
          self.eventRSVPLabel.text = "Not Attending"
        }
      }
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
    eventTitleLabel.text = cgeEvent.title
    eventDescriptionLabel.text = cgeEvent.descriptionText
    eventLocationLabel.text = cgeEvent.address!.components(separatedBy: ", ").first!
    eventDateLabel.text = (cgeEvent.date as! Date).stringWithLongDateShortTime()
    eventDurationLabel.text = cgeEvent.duration == 1 ? "1 Hour" : "\(cgeEvent.duration) Hours"
    if let imageData = cgeEvent.imageData as? Data {
      eventImageView.image = UIImage(data: imageData)
    } else {
      cgeEvent.downloadEventImage() {
        data in
        DispatchQueue.main.async {
          self.eventImageView.image = UIImage(data: data)
        }
      }
    }
    
    tableView.tableFooterView = UIView()
    
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  func handleNetworkError(error: Error?) {
    guard let error = error as? NSError else {
      return
    }
    
    if let alert = createAlertController(forError: error) {
      DispatchQueue.main.async {
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
}

// MARK: - Network Request Protocol

extension EventDetailTableViewController: NetworkRequestProtocol {
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Updating...")
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
    }
  }
}
