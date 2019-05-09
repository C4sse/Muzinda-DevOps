//
//  ViewController.swift
//  Muzinda DevOps
//
//  Created by Casse on 2/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var myRequestsButton: UIBarButtonItem!
    @IBOutlet weak var addRequestButton: UIButton!
    @IBOutlet weak var messagesButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var requestServiceButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerPin: UIImageView!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var messageIcon: UIButton!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    var latitude: Double?
    var longitude: Double?
    let placeHolderText = "Job Descpription..."
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
        mapView.mapType = .hybrid
        checkLocationServices()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: UIControl.Event.valueChanged)
        datePicker.minimumDate = Date() + 3600
        startDateTextField.inputView = datePicker
        
        endDatePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        endDatePicker.addTarget(self, action: #selector(endDatePickerValueChange(sender:)), for: UIControl.Event.valueChanged)
        endDateTextField.inputView = endDatePicker
        promptView.isHidden = true
        bottomView.isHidden = true
        centerPin.isHidden = true
        jobDescription.delegate = self
        jobDescription.text = placeHolderText
        self.jobDescription.textColor = .lightGray
        promptView.layer.cornerRadius = 5
//        promptView.layer.masksToBounds = true
        
        self.promptView.layer.shadowPath =
            UIBezierPath(roundedRect: self.promptView.bounds,
                         cornerRadius: self.promptView.layer.cornerRadius).cgPath
        self.promptView.layer.shadowColor = UIColor.black.cgColor
        self.promptView.layer.shadowOpacity = 0.25
        self.promptView.layer.shadowOffset = CGSize(width: 4, height: 7)
        self.promptView.layer.shadowRadius = 5
        self.promptView.layer.masksToBounds = false
        
        messageIcon.layer.cornerRadius = 25
        messageIcon.clipsToBounds = true
    }
    
    var startDate: Date?
    
    @IBAction func goToMessagesController(_ sender: Any) {
        present(UINavigationController(rootViewController: MessagesController()), animated: true, completion: nil)
    }
    
    @objc func datePickerValueChange(sender: UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        
        startDate = sender.date
        startDateTextField.text = formatter.string(from: sender.date)
        endDateTextField.text = ""
        endDatePicker.minimumDate = formatter.date(from: startDateTextField.text!)! + 3600
        durationLabel.text = ""
    }
    
    @objc func endDatePickerValueChange(sender: UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = DateFormatter.Style.short
        endDateTextField.text = formatter.string(from: sender.date)
        let duration = sender.date.timeIntervalSince(startDate!)
        
        let dateComponents = DateComponentsFormatter()
        dateComponents.allowedUnits = [.hour, .minute]
        dateComponents.unitsStyle = .full
        let forLabel = ("Duration: \(dateComponents.string(from: TimeInterval(duration))!)")
        print(forLabel)
        durationLabel.text! = forLabel
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //        print("workin me \(view.annotation?.coordinate) \(mapView.userLocation.coordinate)")
        
        
    }
    
    @IBAction func requestServicesTapped(_ sender: Any) {
        
        guard let latitude = latitude, let longitude = longitude else { return }
        
        print("l")
        
        let newRequestId = API.Map.REF_MAPREQ.childByAutoId().key
        let newRequestReference = API.Map.REF_MAPREQ.child(newRequestId!)
        let dict = ["latitude": latitude, "longitude": longitude, "title": jobTitleTextField.text!, "price": priceTextField.text!, "locationSize": sizeTextField.text!, "description": jobDescription.text!, "startDate": startDateTextField.text!, "endDate": endDateTextField.text!, "address": addressLabel.text!, "duration": durationLabel.text!] as [String : Any]
        print(dict)
        newRequestReference.setValue(dict, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            self.jobTitleTextField.text = ""
            self.priceTextField.text = ""
            self.sizeTextField.text = ""
            self.addressLabel.text = ""
            self.jobDescription.text = self.placeHolderText
            self.jobDescription.textColor = .lightGray
            self.startDateTextField.text = ""
            self.endDateTextField.text = ""
            self.refreshButton.isEnabled = true
            self.addRequestButton.isHidden = false
            self.messagesButton.isEnabled = true
            self.myRequestsButton.isEnabled = true
            self.centerPin.isHidden = true
            self.promptView.slideOut(from: .left)
            self.bottomView.slideOut(from: .left)
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.promptView.slideOut(from: .left)
        self.bottomView.slideOut(from: .left)
        self.refreshButton.isEnabled = true
        self.addRequestButton.isHidden = false
        self.messagesButton.isEnabled = true
        self.myRequestsButton.isEnabled = true
        self.centerPin.isHidden = true
    }
    
    @IBAction func presentPrompt(_ sender: Any) {
        
        self.helperLabel.text = "Fill in all info"
        self.nextButton.isEnabled = false
        self.promptView.slideIn(from: .left)
        self.refreshButton.isEnabled = false
        self.addRequestButton.isHidden = true
        self.messagesButton.isEnabled = false
        self.myRequestsButton.isEnabled = false
        self.centerPin.isHidden = true
    }
    
    @IBAction func addRequest(_ sender: Any) {
        
        self.addRequestButton.isHidden = true
        self.helperLabel.text = "Choose location"
        self.bottomView.slideIn(from: .left)
        self.centerPin.isHidden = false
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        showMarkers()
        centerViewOnUserLocation()
    }
    func getPins() {
        
        API.Map.observeMap{ (pin) in
            //            print("##### \(pin.latitude) \(pin.longitude) \(pin.name)")
            self.pins.append(pin)
        }
    }
    
    func showMarkers() {
        
        if pins.count == 0 { return }
        
        for i in 0...pins.count - 1 {
            let coordinateValue = CLLocationCoordinate2D(latitude: Double(pins[i].latitude!), longitude: Double(pins[i].longitude!))
            
            let pin = customPin.init(pinTitle: pins[i].title, pinSubtitle: pins[i].price!, location: coordinateValue)
            self.mapView.addAnnotation(pin)
            self.mapView.delegate = self
            self.mapView.reloadInputViews()
        }
    }
    
    let regionInMeters: Double = 3000
    
    func setUpLocationmanager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        centerViewOnUserLocation()
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
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            if !centerPin.isHidden { return }
            guard let location = locations.last else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        if centerPin.isHidden { return }
        
        
        guard self.previousLocation != nil else { return }
        
//        guard center.distance(from: previousLocation) > 50 else { return }
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
            
            self.latitude = center.coordinate.latitude
            self.longitude = center.coordinate.longitude
            
            DispatchQueue.main.async {
                self.addressLabel.text = ("\(streetName) \(streetNumber)")
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        self.jobDescription.textColor = .black
        
        if(self.jobDescription.text == placeHolderText) {
            self.jobDescription.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == "") {
            self.jobDescription.text = placeHolderText
            self.jobDescription.textColor = .lightGray
        }
    }
}

