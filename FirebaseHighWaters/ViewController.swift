//
//  ViewController.swift
//  FirebaseHighWaters
//
//  Created by Gonzalo Alfonso on 16/09/2021.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

// MARK: ViewController class
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  // MARK: - Properties
  @IBOutlet weak var mapView: MKMapView!
  private var locationManager: CLLocationManager?
  private var rootRef: DatabaseReference?

  // MARK: - LifeCycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rootRef = Database.database().reference()
    self.locationManager = CLLocationManager()
    self.locationManager?.delegate = self
    
    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager?.distanceFilter = kCLDistanceFilterNone
    
    self.locationManager?.requestWhenInUseAuthorization()
    
    self.mapView.showsUserLocation = true
    self.mapView.delegate = self
    
    self.locationManager?.startUpdatingLocation()
    
    setupUI()
   
    populateFloodedRegions()
    
  }
  
  // MARK: - Methods
  func setupUI() {
    
    let addFloodButton = UIButton(frame: CGRect.zero)
    addFloodButton.setImage(UIImage(named: "add-button"), for: .normal)
    
    addFloodButton.addTarget(self, action: #selector(addFloodAnnotationButtonPressed), for: .touchUpInside)
    addFloodButton.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(addFloodButton)
    
    addFloodButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    addFloodButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
    addFloodButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    addFloodButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if let location = locations.first {
      
      let coordinate = location.coordinate
      let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  func populateFloodedRegions() {
    
    let floodedRegionsRef = self.rootRef?.child("flooded-regions")
    
    floodedRegionsRef?.observe(.value) { snapshot in
      
      let floodDictionaries = snapshot.value as? [String:Any] ?? [:]
      
      for (key, _) in floodDictionaries {
        
        if let floodDict = floodDictionaries[key] as? [String:Any] {
          
          if let flood = Flood(dictionary: floodDict) {
             
            DispatchQueue.main.async {
              
              let floodAnnotation = MKPointAnnotation()
              floodAnnotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
              
              self.mapView.addAnnotation(floodAnnotation)
              
            }
          }
        }
      }
    }
  }
  
  // MARK: - ButtonPressed method
  @objc func addFloodAnnotationButtonPressed(sender: Any) {
    
    if let location = self.locationManager?.location {
      
      let floodAnnotation = MKPointAnnotation()
      floodAnnotation.coordinate = location.coordinate
      self.mapView.addAnnotation(floodAnnotation)
      
      let coordinate = location.coordinate
      let flood = Flood(latitude: coordinate.latitude, longitude: coordinate.longitude)
      
      let floodedRegionsRef = self.rootRef?.child("flooded-regions")
      let floodRef = floodedRegionsRef?.childByAutoId()
      floodRef?.setValue(flood.toDictionary())
      
    }
  }
}

