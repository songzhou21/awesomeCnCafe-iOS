//
//  CafeAnnotation.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/24.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit
import SwiftHEXColors

let defaultColor = UIColor.gray

class CafeAnnotation: PointAnnotation {
    var tintColor = defaultColor
    
    init(cafe: Cafe) {
        super.init(location: cafe)
        
        if let markerColor = cafe.markerColor {
            if let color = UIColor(hexString: markerColor) {
                self.tintColor = color
            }
        }
        
    }
    
}
