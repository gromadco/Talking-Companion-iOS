//
//  OSMNodeTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 04.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest
import Talking_Companion

class OSMNodeTests: XCTestCase {
    
    let node = OSMNode(uid:"1", latitude: 7.0, longitude: 13.0)
    
    func testNodeInit() {
        XCTAssertEqual(node.location.coordinate.latitude, 7.0)
        XCTAssertEqual(node.location.coordinate.longitude, 13.0)
    }
    
    func testNodeInfoAmenity() {
        node.amenity = "amenity"
        XCTAssertEqual(node.amenity!, "amenity")
    }
    
    func testNodeAnnounce() {
        XCTAssertEqual(node.isAnnounced, false)
        node.announce()
        XCTAssertEqual(node.isAnnounced, true)
        node.announce()
        XCTAssertEqual(node.isAnnounced, true)
    }
}
