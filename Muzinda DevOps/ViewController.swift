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
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    
    var pins: [MapModel] = []
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?
     let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPins()
        locationManager.delegate = self
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        checkLocationServices()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: UIControl.Event.valueChanged)
        datePicker.minimumDate = Date() + 3600
        startDateTextField.inputView = datePicker
        
       
        endDatePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        endDatePicker.addTarget(self, action: #selector(endDatePickerValueChange(sender:)), for: UIControl.Event.valueChanged)
        endDateTextField.inputView = endDatePicker
    }
    
    @objc func datePickerValueChange(sender: UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        
        print(sender.date + 120)
        startDateTextField.text = formatter.string(from: sender.date)
        endDateTextField.text = nil
        endDatePicker.minimumDate = formatter.date(from: startDateTextField.text!)! + 3600
        durationLabel.text = nil
    }
    
    @objc func endDatePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        endDateTextField.text = formatter.string(from: sender.date)
        let duration = sender.date.timeIntervalSince(formatter.date(from: startDateTextField.text!)!)
        
        let dateComponents = DateComponentsFormatter()
        dateComponents.allowedUnits = [.hour, .minute]
        dateComponents.unitsStyle = .full
        
        durationLabel.text! = ("Duration: \(dateComponents.string(from: TimeInterval(duration))!)")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("workin me \(view.annotation?.coordinate) \(mapView.userLocation.coordinate)")
        
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        showMarkers()
        centerViewOnUserLocation()
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
            startTrackingUserLocation()
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
    
    func startTrackingUserLocation() {
        print("ran@")
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = ("\(streetName) \(streetNumber)")
            }
        }
    }
}

