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
    
    var intervalsLabels = [String]()
    var intervalsDutation = [Int]()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist"))
        self.intervalsDutation = settings.objectForKey("Durations") as [Int]
        self.intervalsLabels = settings.objectForKey("Labels") as [String]
        
        self.loadDefaults()
        
        let path = NSBundle.mainBundle().pathForResource("po1i", ofType: "json")
        let data = NSData(contentsOfFile: path)
        let jsonParser = GEOJSONParser(jsonData: data)
        jsonParser.parseWithComplitionHandler() { nodes, error in
            if error != nil {
                NSLog("geo json parsing error: \(error!)")
            }
            else {
                NSLog("finished with count: \(nodes.count)")
            }
        }
    }
    
    func loadDefaults() {
        self.selectedRow = NSUserDefaults.standardUserDefaults().integerForKey(kUpdatingInterval)
        self.updatingIntervalPickerView?.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    @IBAction func saveButtonPressed() {
        NSUserDefaults.standardUserDefaults().setInteger(self.selectedRow, forKey: kUpdatingInterval)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kUpdatingIntervalNotification, object: self.selectedRow)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad  {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBAction func downloadExtractButtonPressed() {
        let downloader = ExtractDownloader(delegate: self)
        downloader.downloadCity("odessa")
    }
    
    // MARK - ExtractDownloader delegate
    
    func extractDownloaderFinished(nodes:[OSMNode]) {
        NSLog("odessa nodes: \(nodes.count)")
    }
    
    // MARK: - UIPickerView delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return self.intervalsLabels.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.intervalsLabels[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
