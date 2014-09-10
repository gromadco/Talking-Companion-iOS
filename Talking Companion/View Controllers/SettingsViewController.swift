//
//  SettingsViewController.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 8/6/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ExtractDownloaderDelegate {

    @IBOutlet var updatingIntervalPickerView: UIPickerView?
    
    private var downloader:ExtractDownloader?
    
    private var intervalsLabels = [String]()
    private var intervalsDutation = [Int]()
    private var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloader = ExtractDownloader(delegate: self)
        
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!)
        self.intervalsDutation = settings.objectForKey("Durations") as [Int]
        self.intervalsLabels = settings.objectForKey("Labels") as [String]
        
        self.loadDefaults()
    }
    
    func loadDefaults() {
        self.selectedRow = NSUserDefaults.standardUserDefaults().integerForKey(kUpdatingInterval)
        self.updatingIntervalPickerView?.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    // MARK: - Buttons handlers
    
    @IBAction func saveButtonPressed() {
        NSUserDefaults.standardUserDefaults().setInteger(self.selectedRow, forKey: kUpdatingInterval)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kUpdatingIntervalNotification, object: self.selectedRow)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad  {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBAction func downloadExtractBerdyansk() {
        self.downloadCity("berdyansk")
    }
    
    @IBAction func downloadExtractPoltava() {
        self.downloadCity("poltava")
    }
    
    @IBAction func downloadExtractZaporizhia() {
        self.downloadCity("zaporizhia")
    }
    
    private func downloadCity(city:String) {
        HUDController.sharedController.contentView = HUDContentView.ProgressView();
        HUDController.sharedController.show()
        downloader?.downloadExtractForCity(city)
    }
    
//    @IBAction func downloadJSONExtractButtonPressed(sender: AnyObject) {
//        let path = NSBundle.mainBundle().pathForResource("poi", ofType: "json")
//        let data = NSData(contentsOfFile: path!)
//        let jsonParser = GEOJSONParser(jsonData: data)
//        
//        NSLog("start parsing json")
//        jsonParser.parseWithComplitionHandler() { nodes, error in
//            if error != nil {
//                NSLog("geo json parsing error: \(error!)")
//            }
//            else {
//                NSLog("json parsing. finished with count of nodes: \(nodes.count)")
//                
//                for node in nodes {
//                    let tile = OSMTile(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude, zoom: 16)
//                    var tileId = SQLAccess.saveTile(tile)
//                    if tileId == 0 {
//                        tileId = SQLAccess.idOfTile(tile)
//                    }
//                    SQLAccess.saveNodes([node], forTileId: tileId)
//                }
//                NSLog("json parsing. nodes saved in db")
//            }
//        }
//    }
    
    // MARK: - ExtractDownloader delegate
    
    func extractDownloaderFinished(nodes:[OSMNode]) {
        HUDController.sharedController.hide(animated: true)
    }
    
    func extractDownloaderFailed(error:NSError) {
        HUDController.sharedController.hide(animated: true)
        var msg = "Something has gone wrong"
        if error.code == 404 {
            msg = "Extract for this city not found"
        }
        
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerView delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.intervalsLabels.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.intervalsLabels[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
