//
//  OSMWay.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

class OSMWay : NSObject {
   
    // MARK: - Properties
    
    let wayId:String
    var nodes:Array<String> = Array()
    
    var amenity:String?
    var building:String?
    var name:String?
    var shop:String?
    
    // MARK: - Initializing
    
    init(wayId:String) {
        self.wayId = wayId
    }
    
    // MARK: - Other
    
    func description() -> String {
        var description = isClosedWay() ? "closed" : "open"
        description += " way[\(wayId)]"
        description += " nodes = \(nodes.count)"

        if let amenity = self.amenity {
            description += "; amenity = '\(amenity)'"
        }
        if let building = self.building {
            description += "; building = '\(building)'"
        }
        if let name = self.name {
            description += "; name = '\(name)'"
        }
        if let shop = self.shop {
            description += "; shop = '\(shop)'"
        }
        
        return description
    }
    
    func isClosedWay() -> Bool {
        if (nodes.count > 1) {
            return nodes.first == nodes.last
        }
        return false
    }
    
    func centerWithNodes(nodes:[OSMNode]) -> CLLocation {
        var minLt = 180.0
        var maxLt = -180.0
        var minLg = 180.0
        var maxLg = -180.0
        
        for node in nodes {
            if minLt > node.location.coordinate.latitude {
                minLt = node.location.coordinate.latitude
            }
            if maxLt < node.location.coordinate.latitude {
                maxLt = node.location.coordinate.latitude
            }
            if minLg > node.location.coordinate.longitude {
                minLt = node.location.coordinate.latitude
            }
            if maxLg < node.location.coordinate.longitude {
                maxLg = node.location.coordinate.latitude
            }
        }
        let center = CLLocation(latitude: (minLt+maxLt)/2, longitude: (minLg+maxLg)/2)
        return center
    }
}
