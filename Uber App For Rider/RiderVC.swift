//
//  RiderVC.swift
//  Uber App For Rider
//
//  Created by Jeff Kral on 12/16/16.
//  Copyright © 2016 Jeff Kral. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    @IBOutlet weak var myMap: MKMapView!
    
    private var locationManager = CLLocationManager()
    @IBOutlet weak var callUberBtn: UIButton!
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    private var canCallUber = true
    private var riderCanceledRequest = false
    private var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeMessagesForRider()
        UberHandler.Instance.delegate = self

        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            
            
            
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver Location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Rider Location"
            myMap.addAnnotation(annotation)
            
        }
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
        callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
        canCallUber = false
        } else {
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !riderCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Uber Accepted", message: "\(driverName) accepted your request")
            } else {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertTheUser(title: "Uber Canceled", message: "\(driverName) canceled uber request")
            }
        }
        riderCanceledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2DMake(lat, long)
    }

    @IBAction func callUber(_ sender: Any) {
        
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRidersLocation), userInfo: nil, repeats: true)
                
            } else {
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
        }
        
        
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logout() {
            
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
        }
    }
    
    public func alertTheUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
  

}  // class
