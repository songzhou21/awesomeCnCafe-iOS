//
//  MainMapViewController.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/15.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit
import MapKit

class MainMapViewController: UIViewController {
    lazy var mapView: MKMapView = {
      let view = MKMapView()
      return view
    }()
    
    override func loadView() {
        self.view = mapView
    }
    
    override func viewDidLoad() {
    }
    
    // MARK: Initialization
}
