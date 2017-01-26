//
//  EventDetailTableViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit

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
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  // MARK: Actions
  
  func editPressed(_ sender: AnyObject) {
    
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
    eventDescriptionLabel.text = cgeEvent.description
    eventLocationLabel.text = cgeEvent.address!.components(separatedBy: ", ").first!
    eventDateLabel.text = (cgeEvent.date as! Date).stringWithLongDateShortTime()
    eventDurationLabel.text = cgeEvent.duration == 1 ? "1 Hour" : "\(cgeEvent.duration) Hours"
    
    tableView.tableFooterView = UIView()
    
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
  }
}
