//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

let kOneDay:NSTimeInterval = 60 * 60 * 24

// TODO: name is a required property

class OSMNode {
    
    // MARK: - Properties
    
    let uid:String
    let location:CLLocation
    var announcedDate:NSDate?
    lazy var types = [String:String]()
    var name:String!
    
    var isAnnounced:Bool {
        get {
            if announcedDate == nil {
                return false
            }
            
            let announcedInterval = NSDate().timeIntervalSinceDate(announcedDate!)
            if announcedInterval > kOneDay {
                return false
            }
            return true
        }
    }

    // MARK: - Init
    
    init(uid:String, latitude:Double, longitude:Double) {
        self.uid = uid
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Other
    
    func description() -> String {
        let description:String = "element '\(name)' at (\(self.location.coordinate.latitude); \(self.location.coordinate.longitude))"
        return description
    }
    
    func announce() {
        NSLog("node has been announced")
        self.announcedDate = NSDate()
        Database.updateNode(self)
    }
}
