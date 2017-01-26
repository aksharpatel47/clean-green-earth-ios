//
//  SearchEventsViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import CoreData

fileprivate let eventPin = "eventPin"

class SearchEventsViewController: UIViewController {
  
  // MARK: Properties
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  // MARK: Actions
  
  @IBAction func pinLocationToSearch(_ sender: UILongPressGestureRecognizer) {
    
  }
  
  @IBAction func searchButtonPressed(_ sender: AnyObject) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    
    DispatchQueue.main.async {
      self.present(autocompleteController, animated: true, completion: nil)
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
  
  // MARK: Helper Methods
  
  func setupViews() {
    mapView.delegate = self
  }
  
  func showEventsAround(coordinate: CLLocationCoordinate2D) {
    
    let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 50000)
    
    DispatchQueue.main.async {
      self.mapView.setCamera(camera, animated: true)
    }
    
    CGEClient.shared.getEventsAround(coordinate: coordinate) {
      events, error in
      
      guard let events = events, events.count > 0, error == nil else {
        return
      }
      
      DispatchQueue.main.async {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for event in events {
          self.mapView.addAnnotation(event)
        }
        
        if let first = self.mapView.overlays.first {
          let rect = self.mapView.overlays.reduce(first.boundingMapRect, { MKMapRectUnion($0, $1.boundingMapRect) })
          self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 32.0, left: 32.0, bottom: 32.0, right: 32.0), animated: true)
        }
      }
    }
  }
}

// MARK: - Places Autocomplete Controller Delegate

extension SearchEventsViewController: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
    
    showEventsAround(coordinate: place.coordinate)
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("autoCompleteError: ", error)
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - MapView Delegate

//MARK: - MKMapView Delegate
extension SearchEventsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: eventPin)
    pinView.canShowCallout = true
    pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    pinView.animatesDrop = true
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    guard let annotation = view.annotation as? CGEEvent else {
      return
    }
    
    let keys = Array(annotation.entity.attributesByName.keys)
    let object = annotation.dictionaryWithValues(forKeys: keys)
    let context = CGEDataStack.shared.managedObjectContext
    
    DispatchQueue.main.async {
      let entityDescription = NSEntityDescription.entity(forEntityName: "CGEEvent", in: context)
      let newEvent = CGEEvent(entity: entityDescription!, insertInto: context)
      newEvent.setValuesForKeys(object)
      self.performSegue(withIdentifier: Constants.Segues.showEventDetail, sender: newEvent)
    }
  }
}

