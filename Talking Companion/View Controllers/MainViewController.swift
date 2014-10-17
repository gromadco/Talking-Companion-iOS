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

let kDownloadTilesTimeInterval:NSTimeInterval = 5 // 60
let kHideSettingsButtonInterval:NSTimeInterval = 10
let kDefaultZoom = 16
let kKilometer = 1000
let kMaxDistance:CLLocationDistance = CLLocationDistance(10 * kKilometer)
let kSpeachSpeedReduceRate:Float = 2.2 // chosen experimentally by @dudarev

class MainViewController: UIViewController, CLLocationManagerDelegate, OSMTilesDownloaderDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var currentLocation:CLLocation?
    private var previousLocation:CLLocation?
    private var closestPlaceLocation:CLLocation?
    
    private var tilesDownloader:OSMTilesDownloader?
    private let synth = AVSpeechSynthesizer()
    
    private var hideSettingsButtonTimer:NSTimer!
    private var tilesTimer:NSTimer?
    private var announceDistanceTimer:NSTimer?
    private var announceDistanceTimeInterval:NSTimeInterval?
    
    private var nodes = [OSMNode]()
    
    // MARK: - ViewController Methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    func loadLocationManager() {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (self.locationManager.respondsToSelector("requestAlwaysAuthorization")) {
            self.locationManager.requestAlwaysAuthorization()
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func updatingIntervalChanged() {
        announceDistanceTimer?.invalidate()
        
        let index = NSUserDefaults.standardUserDefaults().integerForKey("UpdatingInterval")
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!)
        let durations = settings["Durations"] as [Double]
        announceDistanceTimeInterval = durations[index]
        announceDistanceTimer = NSTimer.scheduledTimerWithTimeInterval(announceDistanceTimeInterval!, target: self, selector: "announceClosestPlace", userInfo: nil, repeats: true)
        announceDistanceTimer?.fire()
    }
    
    // MARK: - Settings Button
    
    func showSettingsButton(recognizer:UIGestureRecognizer) {
        self.settingsButton.hidden = !self.settingsButton.hidden
        
        if self.settingsButton.hidden {
            hideSettingsButtonTimer.invalidate()
        }
        else {
            self.startHideButtonTimer()
        }
    }
    
    func startHideButtonTimer() {
        self.hideSettingsButtonTimer = NSTimer.scheduledTimerWithTimeInterval(kHideSettingsButtonInterval, target: self, selector: "hideSettingsButton", userInfo: nil, repeats: false)
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
        if distanceToClosestPlace > kMaxDistance {
            distance = "over \(Int(kMaxDistance) / kKilometer) km";
        }
        else if distanceToClosestPlace > Double(kKilometer) {
            distance = NSString(format: "%.1lf km", distanceToClosestPlace / Double(kKilometer))
        }
        else {
            distance = "\(Int(distanceToClosestPlace)) m"
        }
        
        if currentLocation != nil && previousLocation != nil {
            let angle = Calculations.thetaForCurrentLocation(currentLocation!, previousLocation: previousLocation!, placeLocation: closestPlaceLocation!)
            let direction = Direction(angle: angle)
            distance += " \(direction.description)"
        }
        self.previousLocation = currentLocation
        
        self.speakPlace(closestPlace!, distance: distance);
        
        self.nameLabel.text = closestPlace!.name
        self.distanceLabel.text = "\(distance)"
        self.typeLabel.text = closestPlace!.type
    }
    
    func speakPlace(place:OSMNode, distance:String) {
        if !place.isAnnounced {
            let placeString = "\(place.type). \(place.name!), \(distance)"
            let utterance = AVSpeechUtterance(string: placeString)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate / kSpeachSpeedReduceRate
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
        self.checkLocationsPermissions(CLLocationManager.locationServicesEnabled())
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        NSLog("location manager error: \(error)")
    }
    
    // start or stop downloading
    func checkLocationsPermissions(isLocationEnabled:Bool) {
        if isLocationEnabled {
            tilesTimer = NSTimer.scheduledTimerWithTimeInterval(kDownloadTilesTimeInterval, target: self, selector: "downloadNeighboringTiles", userInfo: nil, repeats: true)
            tilesTimer?.fire()
            self.updatingIntervalChanged()
        }
        else {
            tilesTimer?.invalidate()
            announceDistanceTimer?.invalidate()
        }
        
        self.statusLabel.text = isLocationEnabled ? "" : "Allow location access";
    }
}
