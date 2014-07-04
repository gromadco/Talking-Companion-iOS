//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

class OSMNode: NSObject {
    
    // MARK: - Properties
    
    var location:CLLocation
    var user:String
    var isAnnounced = false
    
    var amenity:String?
    var name:String?
    var operator:String?
    var shop:String?
    
    // MARK: - Initializing

    init(latitude:Double, longitude:Double, user:NSString) {
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
        self.isAnnounced = true;
    }
}

