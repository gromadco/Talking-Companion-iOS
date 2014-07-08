//
//  OSMBoundingBoxTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 07.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest
import Talking_Companion

class OSMBoundingBoxTests: XCTestCase {
    
    func testInit() {
        var tile = OSMTile(x: 1, y: 1, zoom: 16)
        var box = OSMBoundingBox(tile: tile)
        
//        XCTAssertEqual(box.north, 85.05065487)
//        XCTAssertEqual(box.south, 85.05018093)
//        XCTAssertEqual(box.west, -179.9945068)
//        XCTAssertEqual(box.east, -179.9890136)
    }
    
    func testUrl() {
        var tile = OSMTile(x: 1, y: 1, zoom: 16)
        var box = OSMBoundingBox(tile: tile)
        
        XCTAssertEqual(box.url, "http://api.openstreetmap.org/api/0.6/map?bbox=-179.994506835938,85.0501809345811,-179.989013671875,85.0506548798275")
    }

}
