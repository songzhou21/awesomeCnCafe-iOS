//
//  CafeAnnotationView.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/24.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import Foundation
import MapKit

class CafeAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CafeAnnotationView {
    func annotationImage(tintColor: UIColor) -> UIImage {
        let backgroundImage = UIImage.init(named: "cafe_background")?.imageWithRenderingMode(.AlwaysTemplate)
        let outlineImage = UIImage(named: "cafe_outline")
        
        let size = (backgroundImage?.size)!
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        tintColor.set()
        
        backgroundImage?.drawInRect(CGRectMake(0, 0, size.width, size.height))
        outlineImage?.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}