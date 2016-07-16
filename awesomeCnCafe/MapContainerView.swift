//
//  MapContainerView.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/16.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit

class MapContainerView: UIView{
    convenience init() {
        self.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    /// disable touch event on self, pass to subViews
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        return hitView == self ? nil : hitView
    }
}