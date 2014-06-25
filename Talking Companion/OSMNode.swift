//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class OSMNode: NSObject {
    
    // MARK: - Properties
    
    var latitude:Double
    var longitude:Double
    
    var user:String
    var amenity:String?
    var shop:String?
    var operator:String?
    
    // MARK: - Initializing

    init(latitude:Double, longitude:Double, user:NSString) {
        self.latitude = latitude
        self.longitude = longitude
        self.user = user
    }
    
    // MARK: - Other

    func description() -> String {
        var description:String = "node at (\(self.latitude); \(self.longitude)) by user '\(user)'"
        
        if let amenity = self.amenity {
            description += "; amenity = '\(amenity)'"
        }
        if let shop = self.shop {
            description += "; shop = '\(shop)'"
        }
        if let operator = self.operator {
            description += "; operator = '\(operator)'"
        }
        
        return description
    }
    
    func coordinates() -> String {
        return "(\(self.latitude); \(self.longitude))"
    }
}

