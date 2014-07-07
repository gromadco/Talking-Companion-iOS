//
//  OSMWayTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 05.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest
import Talking_Companion

class OSMWayTests: XCTestCase {

    func testWayInit() {
        let way = OSMWay(wayId: "my_id", user: "serejahh")
        
        XCTAssertEqual(way.wayId, "my_id")
        XCTAssertEqual(way.user, "serejahh")
        XCTAssertEqual(way.nodes.count, 0)
        XCTAssertEqual(way.isClosedWay(), false)
    }
    
    func testClosedWay() {
        let way = OSMWay(wayId: "my_id", user: "serejahh")
        
        way.nodes.append("node1")
        way.nodes.append("node2")
        way.nodes.append("node1")
        XCTAssertEqual(way.isClosedWay(), true)
    }
    
    func testOpenWay() {
        let way = OSMWay(wayId: "my_id", user: "serejahh")
        
        way.nodes.append("node1")
        way.nodes.append("node2")
        way.nodes.append("node3")
        XCTAssertEqual(way.isClosedWay(), false)
    }
    
    func testAllProperties() {
        XCTFail("Not implemented")
    }
}
