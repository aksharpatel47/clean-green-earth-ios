//
//  SearchEventsViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SearchEventsViewController: UIViewController {
  
  // MARK: Properties
  var mapView: GMSMapView!
  var marker: GMSMarker?
  
  // MARK: Outlets
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  deinit {
    mapView.removeObserver(self, forKeyPath: "myLocation")
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
    mapView = GMSMapView()
    mapView.delegate = self
    mapView.isMyLocationEnabled = true
    
    view = mapView
    
    mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    mapView.removeObserver(self, forKeyPath: "myLocation")
    
    guard let myLocation = change?[.newKey] as? CLLocation else {
      return
    }
    
    let camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 11.0)
    
    DispatchQueue.main.async {
      self.mapView.animate(to: camera)
    }
  }
  
  func showEventsAround(coordinate: CLLocationCoordinate2D) {
    
    let coordinateCamera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 11.0)
    
    CGEClient.shared.getEventsAround(coordinate: coordinate) {
      events, error in
      
      guard let events = events, events.count > 0, error == nil else {
        DispatchQueue.main.async {
          self.mapView.animate(to: coordinateCamera)
        }
        // TODO: Handle Error
        return
      }
      
      DispatchQueue.main.async {
        self.mapView.clear()
        
        var bounds = GMSCoordinateBounds()
        
        for event in events {
          bounds = bounds.includingCoordinate(event.coordinate)
          let marker = GMSMarker(position: event.coordinate)
          marker.title = "\(event.title) @ \(event.locationName)"
          marker.snippet = event.locationAddress
          marker.map = self.mapView
          marker.userData = event
        }
        
        let camera = self.mapView.camera (for: bounds, insets: UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32))
        
        self.mapView.animate(to: camera!)
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

extension SearchEventsViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    guard let eventData = marker.userData as? CGEEvent else {
      return
    }
    
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: Constants.Segues.showEventDetail, sender: eventData)
    }
  }
}
