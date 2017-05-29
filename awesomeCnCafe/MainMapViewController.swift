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
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:(self.navigationController?.navigationBar.frame)!.height),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    func initToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leftAnchor.constraint(equalTo: self.containerView.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
            toolbar.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: toolbar_height)
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
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentCityDidChange(_:)), name: NSNotification.Name(rawValue: currentCityDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentCityDidSupport(_:)), name: NSNotification.Name(rawValue: currentCityDidSupportNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentCityNotSupport(_:)), name: NSNotification.Name(rawValue: currentCityNotSupportNotification), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(coordinate: mapView.centerCoordinate)
        locationManager.getCurrentCity(withLocation: location)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView?
        
        switch type(of: annotation) {
        case is CafeAnnotation.Type:
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: cafe_annotation_identifier)
            if annotationView == nil {
                annotationView = CafeAnnotationView(annotation: annotation, reuseIdentifier: cafe_annotation_identifier)
                annotationView?.canShowCallout = true
                
//                let detailButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
//                let image = UIImage(named: "map_disclosure")
//                detailButton.setImage(image, forState: .Normal)
                
                let detailButton = UIButton(type: .detailDisclosure)
                detailButton.addTarget(self, action: #selector(self.detailButtonTapped(_:)), for: .touchUpInside)
                
                
                let navigationButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                let navigaitonImage = UIImage(named: "action-directions")?.withRenderingMode(.alwaysTemplate)
                navigationButton.setImage(navigaitonImage, for: UIControlState())
                navigationButton.tintColor = UIColor(hex: Color.calloutBlue)
                navigationButton.addTarget(self, action: #selector(self.navigationButtonTapped(_:)), for: .touchUpInside)
                
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        currentSelectedAnnotationView = view
    }
    
    // MARK: Actions
    func detailButtonTapped(_ sender: UIButton) {
        if let annotationView = currentSelectedAnnotationView {
            if let annotation = annotationView.annotation {
                switch type(of: annotation) {
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
    
    func navigationButtonTapped(_ sender: UIButton) {
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
            MKMapItem.openMaps(with: [userLocationItem, destinationItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit])
        } else {
            MKMapItem.openMaps(with: [userLocationItem], launchOptions: nil)
        }
        
    }
    
    // MARK: Private
    @objc fileprivate func currentCityDidChange(_ notification: Notification) {
        let city = notification.userInfo![currentCityKey] as! City
        self.title = city.name
    }
    
    @objc fileprivate func currentCityDidSupport(_ notification: Notification) {
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
    
    @objc fileprivate func currentCityNotSupport(_ notification: Notification) {
        let city = notification.userInfo![currentCityKey] as! City
        debugPrint("\(city.name) not support")
    }
    
    
}


