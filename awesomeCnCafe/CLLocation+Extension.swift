//
//  CLLocation+SZCoordinate.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import MapKit

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude:coordinate.longitude)
    }
}