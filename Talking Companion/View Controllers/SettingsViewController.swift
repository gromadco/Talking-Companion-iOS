//
//  SettingsViewController.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 8/6/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var updatingIntervalPickerView: UIPickerView?
    
    private var intervalsLabels = [String]()
    private var intervalsDutation = [Int]()
    private var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!)!
        self.intervalsDutation = settings["Durations"] as! [Int]
        self.intervalsLabels = settings["Labels"] as! [String]
        
        self.loadDefaults()
    }
    
    func loadDefaults() {
        self.selectedRow = NSUserDefaults.standardUserDefaults().integerForKey(kVoiceFrequency)
        self.updatingIntervalPickerView?.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    // MARK: - Buttons handlers
    
    @IBAction func saveButtonPressed() {
        NSUserDefaults.standardUserDefaults().setInteger(self.selectedRow, forKey: kVoiceFrequency)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kVoiceFrequencyNotification, object: self.selectedRow)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad  {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    // MARK: - UIPickerView delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.intervalsLabels.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return NSLocalizedString(self.intervalsLabels[row], comment: "")
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
