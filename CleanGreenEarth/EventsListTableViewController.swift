//
//  EventsListTableViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit
import Foundation

class EventsListCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var eventAddress: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
}

fileprivate let reuseIdentifier = "eventCell"

class EventsListTableViewController: UITableViewController {
  
  var cgeEvents = [CGEEvent]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    CGEClient.shared.getEvents() {
      events, error in
      
      guard let events = events, error == nil else {
        return
      }
      
      self.cgeEvents = events
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cgeEvents.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EventsListCell
    let event = cgeEvents[indexPath.row]
    DispatchQueue.main.async {
      cell.titleLabel.text = event.title
      cell.dateLabel.text = event.date.stringWithFormat(forDate: .medium, forTime: .short)
      cell.eventAddress.text = event.address.components(separatedBy: ", ").first!
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(cgeEvents[indexPath.row])
  }
}
