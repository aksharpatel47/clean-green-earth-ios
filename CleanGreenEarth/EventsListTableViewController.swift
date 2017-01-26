//
//  EventsListTableViewController.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 26/01/17.
//  Copyright © 2017 Akshar Patel. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import FirebaseAuth

class EventsListCell: UITableViewCell {
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var eventAddressLabel: UILabel!
  @IBOutlet weak var eventDateLabel: UILabel!
}

fileprivate let reuseIdentifier = "eventCell"

class EventsListTableViewController: CoreDataTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    
    let context = CGEDataStack.shared.managedObjectContext
    
    if let currentUser = CGEUser.getUser(withId: nil) {
      let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "CGEEvent")
      fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
      fr.predicate = NSPredicate(format: "owner == %@ OR attendees contains %@", currentUser, currentUser)
      
      self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let fc = fetchedResultsController, let count = fc.sections?[0].numberOfObjects, count == 0 {
      prepareForNetworkRequest()
    }
    
    CGEClient.shared.getEvents() {
      error in
      
      self.updateAfterNetworkRequest()
      
      CGEDataStack.shared.saveChanges()
      
      guard error == nil else {
        
        if let fc = self.fetchedResultsController, let count = fc.sections?[0].numberOfObjects, count == 0 {
          self.updateAfterNetworkRequest()
          
          guard let error = error as? NSError else {
            return
          }
          
          if let alert = createAlertController(forError: error) {
            DispatchQueue.main.async {
              self.present(alert, animated: true, completion: nil)
            }
          }
        }
        
        return
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EventsListCell
    let event = fetchedResultsController?.object(at: indexPath) as! CGEEvent
    
    DispatchQueue.main.async {
      cell.eventTitleLabel.text = event.title
      cell.eventDateLabel.text = (event.date as! Date).stringWithFormat(forDate: .medium, forTime: .short)
      cell.eventAddressLabel.text = event.address!.components(separatedBy: ", ").first!
      if let imageData = event.imageData {
        cell.eventImageView.image = UIImage(data: imageData as Data)
      } else {
        event.downloadEventImage(completionHandler: nil)
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let event = fetchedResultsController?.object(at: indexPath) as! CGEEvent
    
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: Constants.Segues.showEventDetail, sender: event)
    }
  }
  
  // MARK: Navigation Methods
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      return
    }
    
    if identifier == Constants.Segues.showEventDetail {
      guard let detailViewController = segue.destination as? EventDetailTableViewController,
        let event = sender as? CGEEvent else {
          return
      }
      
      detailViewController.cgeEvent = event
    }
  }
}

extension EventsListTableViewController: NetworkRequestProtocol {
  func prepareForNetworkRequest() {
    DispatchQueue.main.async {
      self.showLoadingIndicator(withText: "Updating Events...")
    }
  }
  
  func updateAfterNetworkRequest() {
    DispatchQueue.main.async {
      self.hideLoadingIndicator()
    }
  }
}
