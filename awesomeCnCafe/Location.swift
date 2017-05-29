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
    required init?(map: Map) {
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
    
    func transformFromJSON(_ value: Any?) -> CLLocation? {
        if let coordList = value as? [Double], coordList.count == 2 {
            let coordinate = CLLocationCoordinate2D(latitude: coordList[1], longitude: coordList[0])
            return CLLocation(coordinate: coordinate.toMars())
        }
        
        return nil
    }
    
    func transformToJSON(_ value: CLLocation?) -> [String : AnyObject]? {
        return nil;
    }
}
