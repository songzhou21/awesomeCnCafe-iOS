//
//  LocationManager.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit

let currentCityDidChangeNotification = "currentCityDidChangedNotification"
let currentCityDidSupportNotification = "currentCityDidSupportNotification"
let currentCityNotSupportNotification = "currentCityNotSupportNotification"

let current_city = "current city"

class LocationManager: NSObject, CLLocationManagerDelegate {
    typealias LocationManagerCallback = (CLLocationManager, CLLocation) -> ()
    
    var manager: [CLLocationManager: LocationManagerCallback] = [:]
    static let sharedInstance = LocationManager()
    
    static let lastCityCoordinate : CLLocationCoordinate2D? = {
        if let coordinateArray = Settings.sharedInstance[lastLocation] as? [Double] where coordinateArray.count == 2 {
            let coordinate = CLLocationCoordinate2DMake(coordinateArray.first!, coordinateArray.last!)
            if CLLocationCoordinate2DIsValid(coordinate) {
                return coordinate
            }
            
        }
        
        return nil
    }()
    
    static let geoCoder = CLGeocoder()
    static var currentCity: City? {
        didSet {
            if let city = currentCity {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: currentCityDidChangeNotification, object: sharedInstance, userInfo: [current_city: city]))
                
                if  NetworkManaer.sharedInstance.supportCities[city.pinyin] != nil {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: currentCityDidSupportNotification, object: sharedInstance, userInfo: [current_city: city]))
                } else {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: currentCityNotSupportNotification, object: sharedInstance, userInfo: [current_city: city]))
                }
            }
            
        }
    }
    
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
    
    func getCurrentCity(withLocation location: CLLocation) {
        self.getCurrentCity(location, success: { (result) in
            if let city = result as? City {
                if let currentCity = LocationManager.currentCity {
                    if currentCity != city {
                        LocationManager.currentCity = city
                    }
                } else {
                    LocationManager.currentCity = city
                }
            }
            }, fail: { (error) in
                debugPrint("get current city with error: \(error.localizedDescription)")
            }
        )
        
    }

    private func getCurrentCity(location: CLLocation, completion:(city: City?, error: NSError?) -> Void) {
        LocationManager.geoCoder.reverseGeocodeLocation(location) { (placeMarks: [CLPlacemark]?, error: NSError?) in
            if let error = error {
                debugPrint("get reverse geo with error: \(error.localizedDescription)")
                completion(city: nil, error: error)
            } else {
                if let mark = placeMarks?.first {
                    if let name = mark.name {
                        debugPrint("get reverse geo success: \(name)")
                    } else {
                        debugPrint("get reverse geo success with getting name failed")
                    }
                    
                    if let locality = mark.locality {
                        let cityMutableString = NSMutableString(string: locality)
                        CFStringTransform(cityMutableString, nil, kCFStringTransformToLatin, false)
                        CFStringTransform(cityMutableString, nil, kCFStringTransformStripDiacritics, false)
                        
                        var cityName = cityMutableString as String
                        cityName = cityName.stringByReplacingOccurrencesOfString(" ", withString: "")
                        if cityName.hasSuffix("shi") {
                            cityName.removeRange(cityName.rangeOfString("shi")!)
                        }
                        
                        let city = City(pinyin: cityName)
                        city.location = mark.location
                        city.name = locality
                        completion(city: city, error: error)
                    }
                    
                } else {
                    completion(city: nil, error: nil)
                }
            }
        }
    }
    
    private func getCurrentCity(location: CLLocation, success: Success, fail: Fail) {
       self.reverseGeocodeLocation(location, success: { (result) in
            if let mark = result as? CLPlacemark {
                if let name = mark.name {
                    debugPrint("get reverse geo success: \(name)")
                } else {
                    debugPrint("get reverse geo success with getting name failed")
                }
                
                if let locality = mark.locality {
                    let cityMutableString = NSMutableString(string: locality)
                    CFStringTransform(cityMutableString, nil, kCFStringTransformToLatin, false)
                    CFStringTransform(cityMutableString, nil, kCFStringTransformStripDiacritics, false)
                    
                    var cityName = cityMutableString as String
                    cityName = cityName.stringByReplacingOccurrencesOfString(" ", withString: "")
                    if cityName.hasSuffix("shi") {
                        cityName.removeRange(cityName.rangeOfString("shi")!)
                    }
                    
                    let city = City(pinyin: cityName)
                    city.location = mark.location
                    city.name = locality
                    success(result: city)
                }
                
            }
        }, fail: { (error) in
            fail(error: error)
        }, retry: 3)
    }
    
    private func reverseGeocodeLocation(location: CLLocation, success: Success, fail: Fail, retry: UInt) {
        LocationManager.geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let error = error {
                if retry != 0 {
                    debugPrint("get reverse geo code retry:\(retry), error: \(error.localizedDescription)")
                    self.reverseGeocodeLocation(location, success: success, fail: fail, retry: retry - 1)
                } else {
                    debugPrint("get reverse geo code fail, error: \(error.localizedDescription)")
                    fail(error: error)
                }
            } else {
                if let mark = placeMarks?.first {
                    debugPrint("get reverse geo code success:\(mark.name!)")
                   success(result: mark)
                }
            }
        }
    }
    
    
}