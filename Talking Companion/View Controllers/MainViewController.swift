//
//  MainViewController.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var currentSpeedLabel: UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocationManager()
    }
    
    func loadLocationManager() {
        var manager = CLLocationManager()
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()

    }
    
    @IBAction func loadManagerButtonPressed(sender: AnyObject) {
        loadLocationManager()
    }
    
    func locationUpdated(newLocation: CLLocation!, oldLocation: CLLocation!) {
        
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)
    {
        let speed = newLocation.speed * 3600.0/1000.0;
        currentSpeedLabel.text = "\(speed)"
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: AnyObject[]!)
    {
        
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        
    }
}
