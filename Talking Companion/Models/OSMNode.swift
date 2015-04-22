//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

let kOneDay:NSTimeInterval = 60*60*24

// TODO: name is a required property

class OSMNode {
    
    // MARK: - Properties
    
    var uid:String
    var location:CLLocation
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
                return false;
            }
            return true;
        }
    }

    // MARK: - Init
    
    init(uid:String, latitude:Double, longitude:Double) {
        self.uid = uid
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Other
    
    // TODO: impelement
    var type:String {
        var type:String = "\(count(types)) types: \(types)"
        return type
    }
    
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
