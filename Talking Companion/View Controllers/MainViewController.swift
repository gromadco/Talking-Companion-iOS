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

let downloadTilesTimeInterval:NSTimeInterval = 5 // 60
let hideSettingsButtonInterval:NSTimeInterval = 10
let kDefaultZoom = 16
let KILOMETER = 1000
let maxDistance:CLLocationDistance = CLLocationDistance(10 * KILOMETER)

class MainViewController: UIViewController, CLLocationManagerDelegate, OSMTilesDownloaderDelegate {
    
    // MARK: - Public
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Private
    
    private let locationManager = CLLocationManager()
    private var currentLocation:CLLocation?
    private var previousLocation:CLLocation?
    private var closestPlaceLocation:CLLocation?
    
    private var tilesDownloader:OSMTilesDownloader?
    private let synth = AVSpeechSynthesizer()
    
    private var hideSettingsButtonTimer:NSTimer?
    private var tilesTimer:NSTimer?
    private var announceDistanceTimer:NSTimer?
    private var announceDistanceTimeInterval:NSTimeInterval?
    
    private var nodes = [OSMNode]()
    
    // MARK: - ViewController Methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController.setNavigationBarHidden(true, animated: true)
        
        self.previousLocation = nil
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("path to documents: \(NSHomeDirectory())")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatingIntervalChanged", name: "UpdatingIntervalNotification", object: nil)
        self.settingsButton.setTitle("⚙", forState: .Normal)
        
        self.updateNodesFromDB()
        
        let tap = UITapGestureRecognizer(target: self, action: "showSettingsButton:")
        self.view.addGestureRecognizer(tap)
        self.startHideButtonTimer()
        
        self.tilesDownloader = OSMTilesDownloader(delegate: self)
        self.tilesDownloader?.delegate = self
        loadLocationManager()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    func loadLocationManager() {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // TODO: detect iOS 8
        //self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func updatingIntervalChanged() {
        if announceDistanceTimer?.valid == true {
            announceDistanceTimer?.invalidate()
        }
        
        let index = NSUserDefaults.standardUserDefaults().integerForKey("UpdatingInterval")
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!)
        let durations = settings["Durations"] as [Double]
        announceDistanceTimeInterval = durations[index]
        announceDistanceTimer = NSTimer.scheduledTimerWithTimeInterval(announceDistanceTimeInterval!, target: self, selector: "announceClosestPlace", userInfo: nil, repeats: true)
    }
    
    // MARK: - Settings Button
    
    func showSettingsButton(recognizer:UIGestureRecognizer) {
        self.settingsButton.hidden = !self.settingsButton.hidden
        
        if self.settingsButton.hidden {
            if hideSettingsButtonTimer?.valid == true {
                hideSettingsButtonTimer?.invalidate()
            }
        }
        else {
            self.startHideButtonTimer()
        }
    }
    
    func startHideButtonTimer() {
        self.hideSettingsButtonTimer = NSTimer.scheduledTimerWithTimeInterval(hideSettingsButtonInterval, target: self, selector: "hideSettingsButton", userInfo: nil, repeats: false)
    }
    
    func hideSettingsButton() {
        self.settingsButton.hidden = true
    }
    
    @IBAction func showSettingsViewController(sender: UIButton!) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.performSegueWithIdentifier("Popover Settings", sender: sender)
        }
        else {
            self.performSegueWithIdentifier("Push Settings", sender: sender)
        }
    }
    
    // MARK: - Fetching Nodes
    
    func updateNodesFromDB() {
        if let current = self.currentLocation {
            let centerTile = OSMTile(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude, zoom: kDefaultZoom)
            
            var tmpNodes = [OSMNode]()
            let neighboringTiles = centerTile.neighboringTiles()
            for currentTile in neighboringTiles {
                tmpNodes += SQLAccess.nodesForTile(currentTile)
            }
            self.nodes = tmpNodes
            
            if currentLocation?.speed > 0 {
                self.statusLabel.text = ""
            }
            else {
                self.statusLabel.text = "Start moving\n\(self.nodes.count) poins around"
            }
            self.statusLabel.text = "Start moving\n\(self.nodes.count) poins around"
        }
    }

    func downloadNeighboringTiles() {
        if let current = self.currentLocation {
            self.statusLabel.text = "Loading..."
            let centerTile = OSMTile(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude, zoom: kDefaultZoom)
            self.tilesDownloader?.downloadNeighboringTilesFor(tile: centerTile)
            //NSLog(@"downloading neighboring tiles for tile(%lf; %lf) @ %@", coordinates.latitude, coordinates.longitude, [[OSMBoundingBox alloc] initWithTile:centerTile].url);
        }
    }
    
    // MARK: - OSMTileDownloader Delegate
    
    func tilesDownloaded() {
        self.updateNodesFromDB()
    }
    
    // MARK: - Place details
    
    func announceClosestPlace() {
        var closestPlace:OSMNode?
        var distanceToClosestPlace:CLLocationDistance = Double(INT_MAX)
        
        for node in nodes {
            let distance = currentLocation!.distanceFromLocation(node.location)
            if distanceToClosestPlace > distance {
                distanceToClosestPlace = distance
                closestPlace = node
            }
        }
        
        if closestPlace == nil {
            return
        }
        closestPlaceLocation = closestPlace!.location
        
        var distance = ""
        if distanceToClosestPlace > maxDistance {
            distance = "over \(Int(maxDistance) / KILOMETER) km";
        }
        else {
            if distanceToClosestPlace > Double(KILOMETER) {
                distance = NSString(format: "%.1lf km", distanceToClosestPlace / Double(KILOMETER))
            }
            else {
                distance = "\(Int(distanceToClosestPlace)) m"
            }
        }
        
        if currentLocation != nil && previousLocation != nil {
            let angle = Calculations.thetaForCurrentLocation(currentLocation!, previousLocation: previousLocation!, placeLocation: closestPlaceLocation!)
            let direction = Direction(angle: angle)
            distance += " \(direction.description)"
        }
        self.previousLocation = currentLocation
        
        if closestPlace?.isAnnounced == false {
            self.speakPlace(closestPlace!, distance: distanceToClosestPlace)
        }
        
        self.nameLabel.text = closestPlace!.name
        self.distanceLabel.text = "\(distance)"
        self.typeLabel.text = closestPlace!.type
    }
    
    func speakPlace(place:OSMNode, distance:CLLocationDistance) {
        if distance > 0 {
            let placeString = "Closest place is \(place.name), \(place.type) with distance \(distance) m"
            let utterance = AVSpeechUtterance(string: placeString)
            synth.speakUtterance(utterance)
            place.announce()
            
            NSLog("announce place \"\(placeString)\"")
        }
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)
    {
        self.currentLocation = newLocation;

        if self.previousLocation == nil {
            NSLog("initial coordinates: \(currentLocation?.coordinate.latitude); \(currentLocation?.coordinate.longitude)");
            self.previousLocation = newLocation
            
            self.updateNodesFromDB()
            self.downloadNeighboringTiles()
            self.announceClosestPlace()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        NSLog("location manager status: \(status.toRaw())");
        
        //let locationEnabled = !(status != .Denied && status != .NotDetermined)
        var locationEnabled = false
        if status == .Denied || status == .NotDetermined {
            locationEnabled = false;
        }
        else {
            locationEnabled = true;
        }
        
        self.checkLocationsPermissions(locationEnabled)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        NSLog("location manager error: \(error)")
    }
    
    // start or stop downloading
    func checkLocationsPermissions(isLocationEnabled:Bool) {
        if isLocationEnabled {
            tilesTimer = NSTimer.scheduledTimerWithTimeInterval(downloadTilesTimeInterval, target: self, selector: "downloadNeighboringTiles", userInfo: nil, repeats: true)
            self.updatingIntervalChanged()
        }
        else {
            if tilesTimer?.valid == true {
                tilesTimer?.invalidate()
            }
            if announceDistanceTimer?.valid == true {
                announceDistanceTimer?.invalidate()
            }
        }
        
        self.statusLabel.text = isLocationEnabled ? "" : "Allow location access";
    }
}
