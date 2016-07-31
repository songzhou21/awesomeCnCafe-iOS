//
//  Cafe.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/15.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import ObjectMapper

typealias JSON = [String: AnyObject]
typealias CafeProperty = [String: String]

class Cafe: Location{
    var markerColor: String?
    var markerSymbol: String?
    
    var properties: CafeProperty?
    var networkSpeed: [String]?
    var comment: [Comment]?
    var price: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        markerColor <- map["properties.marker-color"]
        markerSymbol <- map["properties.marker-symbol"]
        networkSpeed <- map["properties.下载速度"]
        price <- map["properties.参考价格"]
        comment <- (map["properties"], CommentTransform())
        properties <- (map["properties"], PropertiesTransform())
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

class CommentTransform: TransformType {
    typealias Object = [Comment]
    typealias JSON = [String: AnyObject]
    
    func transformFromJSON(value: AnyObject?) -> Object? {
        var comments: [Comment]?
        if let dict = value as? [String: AnyObject] {
            for (key, value) in dict {
                if key.hasPrefix("评论") {
                    if comments == nil {
                        comments = [Comment]()
                    }
                    
                    let comment = Comment()
                    comment.content = value as? String
                    let username = matchesForRegexInText("\\(.+\\)", text: key).first
                    
                    if let name = username {
                        let a = String(name.characters.dropFirst())
                        let b = String(a.characters.dropLast())
                        comment.author = Author(userName: b)
                        
                    }
                    
                    comments?.append(comment)
                }
            }
        }
        
        return comments
    }
    
    func transformToJSON(value: Object?) -> JSON? {
        return nil
    }
}

class PropertiesTransform: TransformType {
    typealias Object = CafeProperty
    
    func transformFromJSON(value: AnyObject?) -> Object? {
        var properties: CafeProperty?
        if let dict = value as? JSON {
            let notValidKey = [
                "名称", "下载速度", "marker-color", "marker-symbol", "参考价格"
            ]
            for (key, value) in dict {
                if key.lowercaseString.hasPrefix("speedtest")
                    || key.hasPrefix("评论")
                    || notValidKey.contains(key) {
                    continue
                }
                
                if properties == nil {
                    properties = CafeProperty()
                }
                
                properties?[key] = value as? String;
            }
        }
        
        return properties
    }
    
    func transformToJSON(value: Object?) -> JSON? {
        return nil
    }
}