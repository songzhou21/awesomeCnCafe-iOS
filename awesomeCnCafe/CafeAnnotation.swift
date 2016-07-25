//
//  CafeAnnotation.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/24.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit
import SwiftHEXColors

class CafeAnnotation: MKPointAnnotation {
    var tintColor: UIColor?
    
    init(cafe: Cafe) {
        super.init()
        
        self.title = cafe.name
        if let coordinate = cafe.location?.coordinate {
            self.coordinate = coordinate
        }
        
        if let markerColor = cafe.markerColor {
            self.tintColor = UIColor(hexString: markerColor)
        }
    }
}