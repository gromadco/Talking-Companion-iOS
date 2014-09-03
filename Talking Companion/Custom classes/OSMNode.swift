//
//  OSMNode.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 23.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

let oneDay:NSTimeInterval = 60*60*24

class OSMNode: NSObject {
    
    // MARK: - Properties
    
    var uid:String
    var location:CLLocation
    var announcedDate:NSDate?
    var isAnnounced:Bool {
        get {
            if announcedDate? == nil {
                return false
            }
            
            var announcedInterval = NSDate.date().timeIntervalSinceDate(announcedDate!)
            if announcedInterval > oneDay {
                return false;
            }
            return true;
        }
    }
    
    // MARK: Element details
    
    var name:String?
    var amenity:String?
    var operatorName:String?
    var shop:String?
    
    // MARK: - Init
    
    init(uid:String, latitude:Double, longitude:Double) {
        self.uid = uid
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Other
    
    // TODO: check an empty strings
    var type:String {
        var type:String = ""
            
        if let amenity = self.amenity {
            if countElements(amenity) > 0 {
                type += "\(amenity), "
            }
        }
        if let operatorName = self.operatorName {
            if countElements(operatorName) > 0 {
                type += "\(operatorName), "
            }
        }
        if let shop = self.shop {
            if countElements(shop) > 0 {
                type += "\(shop), "
            }
        }
            
        // FIXME: rewrite
        if countElements(type) > 0 {
            let rangeReplace = Range<String.Index>(start: type.startIndex, end: type.endIndex)
            type = type.stringByReplacingOccurrencesOfString("_", withString: " ", options: .CaseInsensitiveSearch, range:rangeReplace)
            
            let rangeRemove = Range<String.Index>(start: advance(type.startIndex, countElements(type)-2), end: type.endIndex)
            type.removeRange(rangeRemove)
            
            
        }
        
        return type
    }
    
    func description() -> String {
        let description:String = "element '\(name)' at (\(self.location.coordinate.latitude); \(self.location.coordinate.longitude))"
        return description
    }
    
    func announce() {
        NSLog("node has been announced")
        self.announcedDate = NSDate.date()
        // FIXME: - Make the element as base a class for node and way classes
        //SQLAccess.updateNode(self)
    }
}
