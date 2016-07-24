//
//  City.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit

class City{
    var location: CLLocation?
    var pinyin: String!
    var name: String!
    
    init(pinyin: String) {
        self.pinyin = pinyin
    }
}

extension City: Hashable {
    var hashValue: Int {
        return pinyin.hashValue //change to ID when server side is ready
    }
    
}

extension City: Equatable { }

func == (lhs:City, rhs: City) -> Bool {
    return lhs.pinyin == rhs.pinyin
}