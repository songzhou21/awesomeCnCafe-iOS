//
//  MapView.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit
import MapKit

let delta: CLLocationDegrees = 1000
extension MKMapView {
    func jumpToCoordinateWithDefaultZoomLebel(coordinate: CLLocationCoordinate2D, animated: Bool) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, delta, delta)
        self.setRegion(region, animated: animated)
    }
}

extension CLLocationCoordinate2D {
    func toMars() -> CLLocationCoordinate2D {
        let marsCoordinate = LocationTransform.wgs2gcj(self.latitude, wgsLng: self.longitude)
        
        return CLLocationCoordinate2DMake(marsCoordinate.0, marsCoordinate.1)
    }
    
}