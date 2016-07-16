//
//  Cafe.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/15.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import ObjectMapper

class Cafe: Location{
    var markerColor: String?
    var markerSymbol: String?
    
    var properties: [String: AnyObject]?
//    var comment: Comment?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        markerColor <- map["properties.marker-color"]
        markerSymbol <- map["properties.marker-symbol"]
        properties <- map["properties"]
    }
    
    
}

class Comment {
    var author: Author?
    var content: String?
}

class Author {
    let userName: String
    
    init(userName: String) {
        self.userName = userName
    }
}

class CafeResponse: Mappable {
    var cafeArray: [Cafe]?
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
       cafeArray <- map["features"]
    }
}