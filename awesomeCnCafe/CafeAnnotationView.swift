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
    func annotationImage(_ tintColor: UIColor) -> UIImage {
        let backgroundImage = UIImage.init(named: "cafe_background")?.withRenderingMode(.alwaysTemplate)
        let outlineImage = UIImage(named: "cafe_outline")
        
        let size = (backgroundImage?.size)!
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        tintColor.set()
        
        backgroundImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        outlineImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
