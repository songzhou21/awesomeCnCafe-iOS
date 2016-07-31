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
import Contacts

let toolbar_height: CGFloat = 44

let cafe_annotation_identifier = "Cafe annotation identifier"

typealias CoordinateHashKey = Int

class MainMapViewController: UIViewController, MKMapViewDelegate {
    // MARK:  Properties
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        
        if let lastCoordiante = LocationManager.sharedManager.lastCityCoordinate {
            view.jumpToCoordinateWithDefaultZoomLebel(lastCoordiante, animated: false)
        }
        
        return view
    }()
    
    var containerView: MapContainerView!
    var toolbar: UIToolbar!
    var userTrackingBarButtonItem: MKUserTrackingBarButtonItem!
    
    lazy var networkManager: NetworkManager = {
        return NetworkManager.sharedInstance
    }()
    
    lazy var locationManager: LocationManager = {
        return LocationManager.sharedManager
    }()
    
    
    lazy var annotationImages = {
        return [UIColor: UIImage]()
    }()
    
    var currentSelectedAnnotationView: MKAnnotationView!
    
    var cafeDict = [CoordinateHashKey: Cafe]()
    
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
    
    // MARK:  View Controller LifeCycle
    override func viewDidLoad() {
        mapView.showsUserLocation = true
        mapView.delegate = self;
        
        // change mapView center coordinate to user location on first launch
        locationManager.updatingUserLocation(CLLocationManager()) {[unowned self] (manager: CLLocationManager, location: CLLocation) in
            self.mapView.jumpToCoordinateWithDefaultZoomLebel(location.coordinate.toMars(), animated: false)
            manager.stopUpdatingLocation()
            
            self.locationManager.getCurrentCity(withLocation: location)
        }
        
        networkManager.requestSupportCities()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.currentCityDidChange(_:)), name: currentCityDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.currentCityDidSupport(_:)), name: currentCityDidSupportNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.currentCityNotSupport(_:)), name: currentCityNotSupportNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(coordinate: mapView.centerCoordinate)
        locationManager.getCurrentCity(withLocation: location)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView?
        
        switch annotation.dynamicType {
        case is CafeAnnotation.Type:
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(cafe_annotation_identifier)
            if annotationView == nil {
                annotationView = CafeAnnotationView(annotation: annotation, reuseIdentifier: cafe_annotation_identifier)
                annotationView?.canShowCallout = true
                
                let detailButton = UIButton(type: .DetailDisclosure)
                detailButton.addTarget(self, action: #selector(self.detailButtonTapped(_:)), forControlEvents: .TouchUpInside)
                
                let navigationButton = UIButton(type: .DetailDisclosure)
                navigationButton.addTarget(self, action: #selector(self.navigationButtonTapped(_:)), forControlEvents: .TouchUpInside)
                
                annotationView?.rightCalloutAccessoryView = detailButton
                annotationView?.leftCalloutAccessoryView = navigationButton
                
            }
            
            
           let cafeAnnotationView = annotationView as! CafeAnnotationView
            if let cafeAnnotation = annotation as? CafeAnnotation {
                if let image = annotationImages[cafeAnnotation.tintColor] {
                    cafeAnnotationView.image = image
                } else {
                    let image = cafeAnnotationView.annotationImage(cafeAnnotation.tintColor)
                    cafeAnnotationView.image = image
                    
                    annotationImages[cafeAnnotation.tintColor] = image
                }
            }
            
            view = cafeAnnotationView
        default: break
            
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        currentSelectedAnnotationView = view
    }
    
    // MARK: Actions
    func detailButtonTapped(sender: UIButton) {
        if let annotationView = currentSelectedAnnotationView {
            if let annotation = annotationView.annotation {
                switch annotation.dynamicType {
                case is CafeAnnotation.Type:
                    if let cafeAnnotation = annotation as? CafeAnnotation {
                        if let cafe = cafeDict[cafeAnnotation.coordinate.sz_hashValue()] {
                            self.navigationController?.pushViewController(CafeAnnotationDetailViewController(cafe: cafe), animated: true)
                        }
                        
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    func navigationButtonTapped(sender: UIButton) {
        let userLocationItem = MKMapItem(placemark:MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: [
            CNPostalAddressStreetKey: NSLocalizedString("current_location", comment: "")
            ]))
        
        var destinationItem: MKMapItem?
        if let anntation = currentSelectedAnnotationView.annotation as? CafeAnnotation {
            let cafe = self.cafeDict[anntation.coordinate.sz_hashValue()]!
            destinationItem = MKMapItem(placemark:MKPlacemark(coordinate: (currentSelectedAnnotationView?.annotation?.coordinate)!, addressDictionary: [
            CNPostalAddressStreetKey: cafe.name!
            ]))
        
        }
        
        if let destinationItem = destinationItem {
            MKMapItem.openMapsWithItems([userLocationItem, destinationItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit])
        } else {
            MKMapItem.openMapsWithItems([userLocationItem], launchOptions: nil)
        }
        
    }
    
    // MARK: Private
    @objc private func currentCityDidChange(notification: NSNotification) {
        let city = notification.userInfo![currentCityKey] as! City
        self.title = city.name
    }
    
    @objc private func currentCityDidSupport(notification: NSNotification) {
        let city = notification.userInfo![currentCityKey] as! City
        debugPrint("\(city.name) support")
        if locationManager.requestedCities[city.pinyin] == nil {
            networkManager.getNearbyCafe(inCity: city, completion: { [unowned self] (cafeArray, error) in
                if error == nil {
                    if let cafeArray = cafeArray {
                        for cafe in cafeArray {
                            let ann = CafeAnnotation(cafe: cafe)
                            self.mapView.addAnnotation(ann)
                            
                            self.cafeDict[ann.coordinate.sz_hashValue()] = cafe
                        }
                    }
                }
            })
        }
    }
    
    @objc private func currentCityNotSupport(notification: NSNotification) {
        let city = notification.userInfo![currentCityKey] as! City
        debugPrint("\(city.name) not support")
    }
    
    
}


