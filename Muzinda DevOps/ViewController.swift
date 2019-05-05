//
//  ViewController.swift
//  Muzinda DevOps
//
//  Created by Casse on 2/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var pins: [MapModel] = []
    var tapPins: [MapModel] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        getPins()
        mapView.delegate = self
        mapView?.showsUserLocation = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mapView?.addGestureRecognizer(tapGesture)
        checkLocationServices()
    }
    override func viewDidAppear(_ animated: Bool) {
        checkLocationServices()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("workin me \(view.annotation?.coordinate) \(mapView.userLocation.coordinate)")
        
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        showMarkers()
    }
    func getPins() {
        
        API.Map.observeUsers{ (pin) in
//            print("##### \(pin.latitude) \(pin.longitude) \(pin.name)")
            self.pins.append(pin)
        }
    }
    
    func showMarkers() {
        print(pins.count)
        if pins.count == 0 {
            return
        }
        for i in 0...pins.count - 1 {
            let coordinateValue = CLLocationCoordinate2D(latitude: Double(pins[i].latitude!), longitude: Double(pins[i].longitude!))
            
            let pin = customPin.init(pinTitle: pins[i].name!, pinSubtitle: "", location: coordinateValue)
            self.mapView.addAnnotation(pin)
            self.mapView.delegate = self
            self.mapView.reloadInputViews()
        }
    }
    
    
    let regionInMeters: Double = 100
    
    func setUpLocationmanager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        let location = mapView.userLocation.coordinate
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationmanager()
            checkLocationAuthorization()
        } else {
            // alert error message user need to enable it
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            print("ran@")
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerViewOnUserLocation()
            break
        case .denied:
            //show alert to request permission to turn it on
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // showing alert
            break
        case .authorizedAlways:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
}

