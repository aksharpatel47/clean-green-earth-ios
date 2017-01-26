//
//  SearchEventsViewController.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 23/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchEventsViewController: UIViewController {
  
  // MARK: Properties
  var mapView: GMSMapView!
  
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
    
  }
  
  // MARK: Helper Methods
  
  func setupViews() {
    mapView = GMSMapView()
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
}
