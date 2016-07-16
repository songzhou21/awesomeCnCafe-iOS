//
//  Location.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/15.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit
import ObjectMapper

class Location: Mappable {
    var name: String?
    var location: CLLocation?
    
    // MARK: - Mapping
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["properties.名称"]
        location <- (map["geometry.coordinates"], CLLocationTransform())
    }
    
}

class CLLocationTransform: TransformType {
    typealias Object = CLLocation
    typealias JSON = [String: AnyObject]
    
    func transformFromJSON(value: AnyObject?) -> Object? {
        if let coordList = value as? [Double] where coordList.count == 2 {
            return CLLocation(latitude: coordList[1], longitude: coordList[0])
        }
        
        return nil
    }
    
    func transformToJSON(value: Object?) -> JSON? {
        if let location = value {
            return ["coordinates": [Double(location.coordinate.longitude), Double(location.coordinate.latitude)]]
        }
        
        return nil
    }
}
