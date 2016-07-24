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

let toolbar_height: CGFloat = 44

class MainMapViewController: UIViewController, MKMapViewDelegate {
    // MARK: - Properties
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        
        if let lastCoordiante = LocationManager.lastCityCoordinate {
            view.jumpToCoordinateWithDefaultZoomLebel(lastCoordiante, animated: false)
        }
        
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
        
        // change mapView center coordinate to user location on first launch
        locationManager.updatingUserLocation(CLLocationManager()) {[unowned self] (manager: CLLocationManager, location: CLLocation) in
            self.mapView.jumpToCoordinateWithDefaultZoomLebel(location.coordinate.toMars(), animated: false)
            manager.stopUpdatingLocation()
            
            LocationManager.sharedInstance.getCurrentCity(withLocation: location)
        }
        
        mapView.showsUserLocation = true
        mapView.delegate = self;
        
        NetworkManaer.sharedInstance.requestSupportCities()
        
      
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserverForName(currentCityDidChangeNotification, object:LocationManager.sharedInstance, queue: NSOperationQueue.mainQueue()) { (notification) in
            let city = notification.userInfo![current_city] as! City
            self.title = city.name
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(currentCityDidSupportNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
            let city = notification.userInfo![current_city] as! City
            debugPrint("\(city.name) support")
            NetworkManaer.sharedInstance.getNearbyCafe(inCity: city, completion: { (cafeArray, error) in
                if error == nil {
                    if let cafeArray = cafeArray {
                        for cafe in cafeArray {
                            let ann = MKPointAnnotation()
                            ann.coordinate = (cafe.location?.coordinate)!
                            
                            self.mapView.addAnnotation(ann)
                        }
                    }
                }
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(currentCityNotSupportNotification, object: LocationManager.sharedInstance, queue: NSOperationQueue.mainQueue()) { (notification) in
            let city = notification.userInfo![current_city] as! City
            debugPrint("\(city.name) not support")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: currentCityDidChangeNotification, object: LocationManager.sharedInstance)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: currentCityDidSupportNotification, object: LocationManager.sharedInstance)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: currentCityNotSupportNotification, object: LocationManager.sharedInstance)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(coordinate: mapView.centerCoordinate)
        LocationManager.sharedInstance.getCurrentCity(withLocation: location)
        
    }
    
}

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude:coordinate.longitude)
    }
}

