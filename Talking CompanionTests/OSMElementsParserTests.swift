//
//  OSMElementsParserTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 05.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest
import Talking_Companion

let emptyFile = NSBundle.mainBundle().pathForResource("empty", ofType:"osm")
let donetskFile = NSBundle.mainBundle().pathForResource("map", ofType:"osm")

class OSMElementsParserTests: XCTestCase {

    // MARK: - Nodes
    
    func testParsingNodes() {
        let parser = OSMElementsParser(filePath: donetskFile)
        XCTAssertEqual(parser.nodes.count, 886)
    }
    
    func testNodesWithProperty() {
        let parser = OSMElementsParser(filePath: donetskFile)
        XCTAssertEqual(parser.nodesWithProperty("amenity").count, 8)
    }
    
    func testNodeWithCurrentProperty() {
        let parser = OSMElementsParser(filePath: donetskFile)
        XCTAssertEqual(parser.nodesWithProperty("amenity", equal: "cinema").count, 1)
    }
    
    // MARK: - Ways
    
    func testParsingWays() {
        let parser = OSMElementsParser(filePath: donetskFile)
        XCTAssertEqual(parser.ways.count, 108)
    }
    
    func testWaysWithProperty() {
        let parser = OSMElementsParser(filePath: donetskFile)
        let ways = parser.waysWithProperty("name")
        XCTAssertEqual(ways.count, 16)
    }
    
    // FIXME: crahsed
//    func testNodesOfWay() {
//        let parser = OSMElementsParser(filePath: donetskFile)
//        XCTAssertEqual(parser.ways[0].nodes.count, 3)
//    }
}
