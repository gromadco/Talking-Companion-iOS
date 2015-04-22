//
//  OSMBoundingBoxTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 07.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest

class OSMBoundingBoxTests: XCTestCase {
    
    func testInit() {
        let tile = OSMTile(x: 1, y: 1, zoom: 16)
        let box = OSMBoundingBox(tile: tile)
        
        XCTAssertLessThanOrEqual(abs(box.north - 85.0506548798275), coordinatesThreshold)
        XCTAssertLessThanOrEqual(abs(box.south - 85.0501809345811), coordinatesThreshold)
        XCTAssertLessThanOrEqual(abs(box.west - -179.9945068), coordinatesThreshold)
        XCTAssertLessThanOrEqual(abs(box.east - -179.9890136), coordinatesThreshold)
    }
    
    func testUrl() {
        let tile = OSMTile(x: 1, y: 1, zoom: 16)
        let box = OSMBoundingBox(tile: tile)
        
        XCTAssertEqual(box.url, "http://api.openstreetmap.org/api/0.6/map?bbox=-179.994506835938,85.0501809345811,-179.989013671875,85.0506548798275")
    }
    
    func testEqutable() {
        let tile = OSMTile(x: 1, y: 1, zoom: 16)
        let box1 = OSMBoundingBox(tile: tile)
        let box2 = OSMBoundingBox(tile: tile)
        
        XCTAssertTrue(box1 == box2)
    }
}
