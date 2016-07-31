//
//  CLLocationCoordinate2D+SZHash.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    func sz_hashValue() -> Int {
        return self.latitude.hashValue ^ self.longitude.hashValue
    }
}

extension CLLocationCoordinate2D {
    func toMars() -> CLLocationCoordinate2D {
        let marsCoordinate = LocationTransform.wgs2gcj(self.latitude, wgsLng: self.longitude)
        
        return CLLocationCoordinate2DMake(marsCoordinate.0, marsCoordinate.1)
    }
    
}