//
//  CalculaionsTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 15.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import XCTest
import Talking_Companion
import CoreLocation

class CalculationsTests: XCTestCase {
    
    func testDirectionRight() {
        let current = CLLocation(latitude: -122.032607, longitude: 37.330186)
        let previous = CLLocation(latitude: -122.032674, longitude: 37.330178)
        let place = CLLocation(latitude: -122.032662, longitude: 37.331556)

        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Calculations.directionForAngle(angle)
        
        XCTAssert(direction == .right)
    }
    
    func testDirectionLeft1() {
        let current = CLLocation(latitude: -122.023466, longitude: 37.33262)
        let previous = CLLocation(latitude: -122.023261, longitude: 37.332045)
        let place = CLLocation(latitude: -122.02902, longitude: 37.332454)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Calculations.directionForAngle(angle)
        
        XCTAssert(direction == .left)
    }
    
    func testDirectionLeft2() {
        let current = CLLocation(latitude: -122.08055, longitude: 37.335314)
        let previous = CLLocation(latitude: -122.077351, longitude: 37.333828)
        let place = CLLocation(latitude: -122.08241, longitude: 37.333624)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Calculations.directionForAngle(angle)
        
        XCTAssert(direction == .left)
    }

    func testDirectionBack() {
        let current = CLLocation(latitude: -122.42187738418578, longitude: 37.765032381819346)
        let previous = CLLocation(latitude: -122.42207050323485, longitude: 37.76654206543786)
        let place = CLLocation(latitude: -122.42224216461183, longitude: 37.76813652927959)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Calculations.directionForAngle(angle)

        XCTAssert(direction == .back)
    }

    func testDirectionFront() {
        let current = CLLocation(latitude: -122.42398023605347, longitude: 37.76476097475465)
        let previous = CLLocation(latitude: -122.42634057998656, longitude: 37.764642233850665)
        let place = CLLocation(latitude: -122.41745710372925, longitude: 37.76520201072898)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Calculations.directionForAngle(angle)
        
        XCTAssert(direction == .front)
    }
}
 