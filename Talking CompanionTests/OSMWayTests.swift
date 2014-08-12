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
        let way = OSMWay(wayId: "my_id")
        
        XCTAssertEqual(way.wayId, "my_id")
        XCTAssertEqual(way.nodes.count, 0)
        XCTAssertEqual(way.isClosedWay(), false)
        
        way.nodes.append("node1")
        way.nodes.append("node2")
        way.nodes.append("node1")
        XCTAssertEqual(way.nodes.count, 3)
    }
    
    func testClosedWay() {
        let way = OSMWay(wayId: "my_id")
        
        way.nodes.append("node1")
        way.nodes.append("node2")
        way.nodes.append("node1")
        XCTAssertEqual(way.isClosedWay(), true)
    }
    
    func testOpenWay() {
        let way = OSMWay(wayId: "my_id")
        
        way.nodes.append("node1")
        way.nodes.append("node2")
        way.nodes.append("node3")
        XCTAssertEqual(way.isClosedWay(), false)
    }
    
    func testAllProperties() {
        let way = OSMWay(wayId: "my_id")
        
        way.amenity = "some amenity"
        way.building = "building1"
        way.name = "awesome way"
        way.shop = "shop??"
        
        XCTAssertEqual(way.amenity!, "some amenity")
        XCTAssertEqual(way.building!, "building1")
        XCTAssertEqual(way.name!, "awesome way")
        XCTAssertEqual(way.shop!, "shop??")
    }
}
