//
//  LocationManager.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    typealias LocationManagerCallback = (CLLocationManager, CLLocation) -> ()
    var manager: [CLLocationManager: LocationManagerCallback] = [:]
    
    func updatingUserLocation(manager: CLLocationManager, completion: LocationManagerCallback) {
        if self.manager.count == 0 {
            manager.requestWhenInUseAuthorization()
        }
        
        self.manager[manager] = completion
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    /// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let callback = self.manager[manager] {
            callback(manager, locations.first!)
        }
    }
}