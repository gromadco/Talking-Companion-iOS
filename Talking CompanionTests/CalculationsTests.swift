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

let degreeThreshold = 0.0001

class CalculationsTests: XCTestCase {
    
    func testDirectionRight() {
        let current = CLLocation(latitude: -122.032607, longitude: 37.330186)
        let previous = CLLocation(latitude: -122.032674, longitude: 37.330178)
        let place = CLLocation(latitude: -122.032662, longitude: 37.331556)

        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Direction(angle: angle)
        
        XCTAssert(direction == Direction.Right)
        XCTAssertTrue(direction.description.rangeOfString("right") != nil)
    }
    
    func testDirectionLeft1() {
        let current = CLLocation(latitude: -122.023466, longitude: 37.33262)
        let previous = CLLocation(latitude: -122.023261, longitude: 37.332045)
        let place = CLLocation(latitude: -122.02902, longitude: 37.332454)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Direction(angle: angle)
        
        XCTAssert(direction == .Left)
        XCTAssertTrue(direction.description.rangeOfString("left") != nil)
    }
    
    func testDirectionLeft2() {
        let current = CLLocation(latitude: -122.08055, longitude: 37.335314)
        let previous = CLLocation(latitude: -122.077351, longitude: 37.333828)
        let place = CLLocation(latitude: -122.08241, longitude: 37.333624)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Direction(angle: angle)
        
        XCTAssert(direction == .Left)
    }

    func testDirectionBack() {
        let current = CLLocation(latitude: -122.42187738418578, longitude: 37.765032381819346)
        let previous = CLLocation(latitude: -122.42207050323485, longitude: 37.76654206543786)
        let place = CLLocation(latitude: -122.42224216461183, longitude: 37.76813652927959)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Direction(angle: angle)

        XCTAssert(direction == .Back)
        XCTAssertTrue(direction.description.rangeOfString("back") != nil)

    }

    func testDirectionFront() {
        let current = CLLocation(latitude: -122.42398023605347, longitude: 37.76476097475465)
        let previous = CLLocation(latitude: -122.42634057998656, longitude: 37.764642233850665)
        let place = CLLocation(latitude: -122.41745710372925, longitude: 37.76520201072898)
        
        let angle = Calculations.thetaForCurrentLocation(current, previousLocation: previous, placeLocation: place)
        let direction = Direction(angle: angle)
        
        XCTAssert(direction == .Front)
        XCTAssertTrue(direction.description.rangeOfString("front") != nil)
    }
    
    func testRadiansToDegrees0() {
        let degree = Calculations.radiansToDegrees(0)
        XCTAssertLessThanOrEqual(abs(degree - 0), coordinatesThreshold)
    }
    
    func testRadiansToDegrees45() {
        let degree = Calculations.radiansToDegrees(0.25 * M_PI)
        XCTAssertLessThanOrEqual(abs(degree - 45), coordinatesThreshold)
    }
    
    func testRadiansToDegrees90() {
        let degree = Calculations.radiansToDegrees(0.5 * M_PI)
        XCTAssertLessThanOrEqual(abs(degree - 90), coordinatesThreshold)
    }
    
    func testRadiansToDegrees180() {
        let degree = Calculations.radiansToDegrees(1 * M_PI)
        XCTAssertLessThanOrEqual(abs(degree - 180), coordinatesThreshold)
    }
    
    func testRadiansToDegrees360() {
        let degree = Calculations.radiansToDegrees(2 * M_PI)
        XCTAssertLessThanOrEqual(abs(degree - 360), coordinatesThreshold)
    }
}
 