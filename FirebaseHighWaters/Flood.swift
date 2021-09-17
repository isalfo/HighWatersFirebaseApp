//
//  Flood.swift
//  FirebaseHighWaters
//
//  Created by Gonzalo Alfonso on 16/09/2021.
//

import Foundation

// MARK: Flood struct
struct Flood {
  // MARK: - Properties
  var latitude: Double
  var longitude: Double
  
  // MARK: - Methods
  func toDictionary() -> [String : Any] {
    
    return ["latitude" : self.latitude, "longitude" : self.longitude]
    
  }
}

// MARK: - Flood init extension
extension Flood {
  
  init?(dictionary: [String:Any]) {
    
    guard let latitude = dictionary["latitude"] as? Double,
          let longitude = dictionary["longitude"] as? Double else {
      
      return nil
      
    }
    
    self.longitude = longitude
    self.latitude = latitude
    
  }
}
