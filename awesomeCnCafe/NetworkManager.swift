//
//  NetworkManager.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import Alamofire

let repo_read_me = "https://raw.githubusercontent.com/ElaWorkshop/awesome-cn-cafe/master/README.md"
let base_url = "https://raw.githubusercontent.com/ElaWorkshop/awesome-cn-cafe/master/"

class NetworkManager {
    static let sharedInstance = NetworkManager()
    
    lazy var locationManager: LocationManager = {
        return LocationManager.sharedManager
    }()
    
    func requestSupportCities(){
        Alamofire.request(repo_read_me).responseString { [unowned self](response: DataResponse<String>) in
                        if let string = response.result.value {
                            let cities = self.cityArrayFromString(string)
                            debugPrint("get supported cities count: \(cities.count)")
                            for city in cities {
                                let cityObject = City(pinyin: city)
            
                                self.locationManager.supportCities[city] = cityObject
                            }
            
                            // check if current city is supported
                            if let currentCity = self.locationManager.currentCity {
                                if self.locationManager.supportCities[currentCity.pinyin] != nil {
                                        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: currentCityDidSupportNotification), object: self, userInfo: [currentCityKey: currentCity]))
                                }
                            }
                        }
        };
    }
    
    func getNearbyCafe(inCity city: City, completion: @escaping (_ cafeArray: [Cafe]?, _ error: NSError?) -> Void) {
        if let cityPinyin = city.pinyin, let name = city.name {
            let url = "\(base_url)\(cityPinyin).geojson"
            debugPrint("search nearyby cafe in \(name)")
            debugPrint("requesting \(url)")
            
            Alamofire.request(url).responseObject(completionHandler: { (response: DataResponse<CafeResponse>) in
                let cafeResponse = response.result.value
                
                if let e = response.result.error {
                    completion(cafeResponse?.cafeArray, e as NSError)
                } else {
                    completion(cafeResponse?.cafeArray, nil)
                }
                
                self.locationManager.requestedCities[city.pinyin] = city

            });
        }
    }
    
    // MARK: Private
    fileprivate func cityArrayFromString(_ string: String) -> [String] {
        var result = [String]()
        
        let lines = string.components(separatedBy: CharacterSet.newlines)
        
        for i in 0 ..< lines.count {
            if lines[i].hasPrefix("##") {
                if lines[i].contains("城市列表") { // start section
                    for j in i+1 ..< lines.count {
                        let line = lines[j]
                        if line.hasPrefix("##") { //end section
                            return result
                        }
                        if var city = matchesForRegexInText("\\w+.geojson", text: line).first {
                            if let range = city.range(of: ".geojson") {
                                city.removeSubrange(range)
                                result.append(city)
                            }
                        }
                    }
                }
            }
        }
        
        return result
    }
}


