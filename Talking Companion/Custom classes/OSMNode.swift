//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

var oneDay:NSTimeInterval = 60*60*24

class OSMNode: NSObject {
    
    // MARK: - Properties
    
    var uid:Int
    var location:CLLocation
    var user:String
    var announcedDate:NSDate?
    var isAnnounced:Bool {
        get {
            if announcedDate? == nil {
                return false
            }
            
            var announcedInterval = NSDate.date().timeIntervalSinceDate(announcedDate)
            if announcedInterval > oneDay {
                return false;
            }
            return true;
        }
    }
    
    var amenity:String?
    var name:String?
    var operator:String?
    var shop:String?
    
    var type:String {
        var type:String = ""
        
        if let amenity = self.amenity {
            type += "\(amenity) "
        }
        if let operator = self.operator {
            type += "\(operator) "
        }
        if let shop = self.shop {
            type += "\(shop) "
        }

        return type
    }
    
    // MARK: - Initializing

    init(uid:Int, latitude:Double, longitude:Double, user:NSString) {
        self.uid = uid
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.user = user
    }
    
    // MARK: - Other

    func description() -> String {
        var description:String = "node at (\(self.location.coordinate.latitude); \(self.location.coordinate.longitude))"
        
        if let name = self.name {
            description += "; name = '\(name)'"
        }

        return description
    }
    
    func coordinates() -> String {
        return "(\(self.location.coordinate.latitude); \(self.location.coordinate.longitude))"
    }
    
    func announce() {
        println("announced node")
        self.announcedDate = NSDate.date()
        SQLAccess.updateNode(self)
    }
}

