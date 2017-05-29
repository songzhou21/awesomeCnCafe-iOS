//
//  Utility.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation

func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
    do {
        
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        
        let results = regex.matches(in: text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substring(with: $0.range)}
        
    } catch let error as NSError {
        
        print("invalid regex: \(error.localizedDescription)")
        
        return []
    } catch _ {
        return []
    }
}
