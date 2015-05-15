//
//  Calculations.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 15.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

let kMaxAngle = 360.0

enum Direction:Int {
    case Front
    case Right
    case Back
    case Left
    
    init(angle:Double) {
        switch angle%kMaxAngle {
            case 0 ..< 45: self = .Front
            case 45 ..< 135: self = .Right
            case 135 ..< 225: self = .Back
            case 225 ..< 315: self = .Left
            default: self = .Front
        }
    }
    
    var description:String {
        switch self {
            case Front: return NSLocalizedString("DirectionFront", comment: "")
            case Back:  return NSLocalizedString("DirectionBack", comment: "")
            case Left:  return NSLocalizedString("DirectionLeft", comment: "")
            case Right: return NSLocalizedString("DirectionRight", comment: "")
        }
    }
}

// TODO: impelement optional values as arguments

class Calculations {
    class func thetaForCurrentLocation(currentLocation:CLLocation, previousLocation:CLLocation, placeLocation:CLLocation) -> Double {
        let y1:Double = sin(currentLocation.coordinate.longitude - previousLocation.coordinate.longitude) * cos(currentLocation.coordinate.latitude)
        let x1:Double = cos(previousLocation.coordinate.latitude) * sin(currentLocation.coordinate.latitude) - sin(previousLocation.coordinate.latitude) * cos(currentLocation.coordinate.latitude) * cos(currentLocation.coordinate.longitude - previousLocation.coordinate.longitude)
        let phi1 = radiansToDegrees(atan2(y1, x1))
        
        let y2 = sin(placeLocation.coordinate.longitude - currentLocation.coordinate.longitude) * cos(placeLocation.coordinate.latitude)
        let x2 = cos(currentLocation.coordinate.latitude) * sin(placeLocation.coordinate.latitude) - sin(currentLocation.coordinate.latitude) * cos(placeLocation.coordinate.latitude) * cos(placeLocation.coordinate.longitude - currentLocation.coordinate.longitude)
        let phi2 = radiansToDegrees(atan2(y2, x2))
        
        var theta = phi2 - phi1
        if theta < 0 {
            theta += kMaxAngle
        }
        
        return theta
    }
    
    class func radiansToDegrees(radians:Double) -> Double {
        return 180 / M_PI * radians
    }
}
