//
//  Annotation.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/30.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import MapKit

class PointAnnotation: MKPointAnnotation {
    init(location: Location) {
        super.init()
        
        self.title = location.name
        if let coordinate = location.location?.coordinate {
            self.coordinate = coordinate
        }
    }
}
