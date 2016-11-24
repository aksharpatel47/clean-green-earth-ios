//
//  SearchEventsViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import MapKit

class SearchEventsViewController: UIViewController {
  
  // MARK: Properties
  
  var locationPin: MKAnnotation!
  var locationManager = CLLocationManager()
  
  // MARK: Outlets
  
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showUserLocation()
    locationManager.delegate = self
  }
  
  // MARK: Actions
  
  @IBAction func pinLocationToSearch(_ sender: UILongPressGestureRecognizer) {
    
  }
  
  @IBAction func searchButtonPressed(_ sender: AnyObject) {
    
  }
  
  // MARK: Functions
  
  func showUserLocation() {
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
      mapView.showsUserLocation = true
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }
}

extension SearchEventsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations.count)
  }
}
