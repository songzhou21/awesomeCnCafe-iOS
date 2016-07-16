//
//  MainMapViewController.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/15.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireObjectMapper

let url = "https://raw.githubusercontent.com/ElaWorkshop/awesome-cn-cafe/master/shanghai.geojson"
let toolbar_height: CGFloat = 50

class MainMapViewController: UIViewController {
    // MARK: - Properties
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        
        return view
    }()
    
    lazy var locationManager: LocationManager = {
        let manager = LocationManager()
        return manager
    }()
    
    var containerView: MapContainerView!
    var toolbar: UIToolbar!
    var userTrackingBarButtonItem: MKUserTrackingBarButtonItem!
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initContainerView(){
        containerView = MapContainerView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        
        NSLayoutConstraint.activateConstraints([
            containerView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor),
            containerView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor),
            containerView.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant:CGRectGetHeight((self.navigationController?.navigationBar.frame)!)),
            containerView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor)
            ])
    }
    
    func initToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(toolbar)
        
        NSLayoutConstraint.activateConstraints([
            toolbar.leftAnchor.constraintEqualToAnchor(self.containerView.leftAnchor),
            toolbar.rightAnchor.constraintEqualToAnchor(self.containerView.rightAnchor),
            toolbar.bottomAnchor.constraintEqualToAnchor(self.containerView.bottomAnchor),
            toolbar.heightAnchor.constraintEqualToConstant(toolbar_height)
            ])
    }
    
    override func loadView() {
        self.view = mapView
        
        initContainerView()
        initToolbar()
        
        let userTrackingBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        toolbar.setItems([userTrackingBarButtonItem], animated: false)
        
        
    }
    
    // MARK: - View Controller LifeCycle
    override func viewDidLoad() {
        
        // change mapView center coordinate to user location on launch
        locationManager.updatingUserLocation(CLLocationManager()) {[unowned self] (manager: CLLocationManager, location: CLLocation) in
            self.mapView.jumpToCoordinateWithDefaultZoomLebel(location.coordinate)
            manager.stopUpdatingLocation()
        }
        
        mapView.showsUserLocation = true
        
         Alamofire.request(.GET, url).responseObject { (response: Response<CafeResponse, NSError>) in
               let cafeResponse = response.result.value
            
            for cafe in (cafeResponse?.cafeArray)! {
                let annotation = MKPointAnnotation()
                annotation.coordinate = (cafe.location?.coordinate)!
                annotation.title = cafe.name
                
                self.mapView.addAnnotation(annotation)
            }
        }

    }
    
    // MARK: Initialization
    
}

