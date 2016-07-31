//
//  MKMapView+Extension.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import MapKit

let delta: CLLocationDegrees = 1000

extension MKMapView {
    func jumpToCoordinateWithDefaultZoomLebel(coordinate: CLLocationCoordinate2D, animated: Bool) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, delta, delta)
        self.setRegion(region, animated: animated)
    }
}