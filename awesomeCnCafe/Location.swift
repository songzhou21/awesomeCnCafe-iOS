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
    var location: CLLocation!
    
    // MARK: - Mapping
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["properties.名称"]
        location <- (map["geometry.coordinates"], CLLocationTransform())
    }
    
}

extension Location: Hashable {
    var hashValue: Int {
        return location.coordinate.sz_hashValue()
    }
}

extension Location: Equatable {}
func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.name == rhs.name && lhs.location == rhs.location
}


class CLLocationTransform: TransformType {
    typealias Object = CLLocation
    typealias JSON = [String: AnyObject]
    
    func transformFromJSON(value: AnyObject?) -> Object? {
        if let coordList = value as? [Double] where coordList.count == 2 {
            let coordinate = CLLocationCoordinate2D(latitude: coordList[1], longitude: coordList[0])
            return CLLocation(coordinate: coordinate.toMars())
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
