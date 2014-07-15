//
//  Calculations.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 15.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

enum Direction:Int {
    case front
    case right
    case back
    case left
}

class Calculations: NSObject {
    
    class func thetaForCurrentLocation(currentLocation:CLLocation, previousLocation:CLLocation, placeLocation:CLLocation) -> Double {
        
        let y1:Double = sin(currentLocation.coordinate.longitude - previousLocation.coordinate.longitude) * cos(currentLocation.coordinate.latitude);
        let x1:Double = cos(previousLocation.coordinate.latitude) * sin(currentLocation.coordinate.latitude) - sin(previousLocation.coordinate.latitude)*cos(currentLocation.coordinate.latitude)*cos(currentLocation.coordinate.longitude - previousLocation.coordinate.longitude);
        var phi1 = atan2(y1, x1)
        phi1 = radiansToDegrees(phi1)
        
        let y2 = sin(placeLocation.coordinate.longitude - currentLocation.coordinate.longitude) * cos(placeLocation.coordinate.latitude);
        let x2 = cos(currentLocation.coordinate.latitude) * sin(placeLocation.coordinate.latitude) - sin(currentLocation.coordinate.latitude)*cos(placeLocation.coordinate.latitude)*cos(placeLocation.coordinate.longitude - currentLocation.coordinate.longitude);
        var phi2 = atan2(y2, x2);
        phi2 = radiansToDegrees(phi2)
        
        var theta = Double(abs((phi2 - phi1) % 360))
        
        return theta;
    }
    
    class func radiansToDegrees(radians:Double) -> Double {
        return radians * 180 / M_PI
    }
    
    class func directionForAngle(angle:Double) -> Direction {
        var direction = Direction.front
        switch angle {
            case 0.0 ..< 45.0:
                direction = .front
            case 45.0 ..< 135.0:
                direction = .right
            case 135.0 ..< 225.0:
                direction = .back
            case 225.0 ..< 315.0:
                direction = .left
            case 315.0 ..< 360.0:
                direction = .front
            default:
                direction = .front
        }
        return direction
    }
    
}
