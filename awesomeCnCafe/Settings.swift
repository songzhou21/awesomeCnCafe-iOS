//
//  Settings.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/24.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation

class Settings {
    static let sharedInstance = Settings()
    var dict: NSMutableDictionary!
    var path: String!
    
    fileprivate init () {
        readFromFile()
    }
    
    fileprivate func readFromFile () {
        if let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            path = documentsDir + "/settings.plist"
            
            if !FileManager.default.fileExists(atPath: path) {
                let bundlePath = Bundle.main.path(forResource: "settings", ofType: "plist")!
                do {
                    try FileManager.default.copyItem(atPath: bundlePath, toPath: path)
                } catch _ {
                    
                }
            }
            
            dict = NSMutableDictionary(contentsOfFile: path)
            debugPrint("reading setting.plist from disk with count \(dict.count)")
        }
    }
    
    func writeToFile() {
        setLastLocation()
        
       let success = dict.write(toFile: path, atomically: true)
        
        if success {
            debugPrint("write setting.plist to disk successfull")
        } else {
            debugPrint("write setting.plist to disk fail with path \(path)")
        }
       
    }
    
}


// MARK: Subscript
extension Settings {
    subscript(key: String) -> AnyObject? {
        get {
            return dict.value(forKey: key) as AnyObject
        }
        
        set {
            
            if let value = newValue {
                dict.setValue(value, forKey: key)
            }
        }
    }
}

extension Settings {
    func setLastLocation() {
        if let location = LocationManager.sharedManager.currentCity?.location?.coordinate {
            self[lastLocation] = [location.latitude, location.longitude]
        }
    }
}
