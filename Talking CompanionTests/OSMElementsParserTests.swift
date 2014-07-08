//
//  OSMElementsParserTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 05.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest
import Talking_Companion

class OSMElementsParserTests: XCTestCase {
    
    func testParseFileWithPath() {
        let parser = OSMElementsParser()
        parser.filePath = "path"
        
        XCTAssertEqual(parser.filePath, "path")
    }
    
    func testParseEmpyFile() {
//        let path = NSBundle.mainBundle().pathForResource("empty", ofType:"osm")
//
//        var parser = OSMElementsParser()
//        parser.filePath = path
//        XCTAssertEqual(parser.filePath, path)
//
//        parser.initialize()
//        XCTAssertEqual(parser.nodes.count, 0)
//        XCTAssertEqual(parser.ways.count, 0)
    }
    
//    func testParseIncorrectFilePath() {
//    }
    
    // MARK: - Nodes
    
    func testParsingNodes() {
        let parser = OSMElementsParser()
        parser.initialize()
        XCTAssertEqual(parser.nodes.count, 886)
    }
    
    func testNodesWithProperty() {
        let parser = OSMElementsParser()
        parser.initialize()
        XCTAssertEqual(parser.nodesWithProperty("amenity").count, 8)
    }
    
    func testNodeWithCurrentProperty() {
        let parser = OSMElementsParser()
        parser.initialize()
        XCTAssertEqual(parser.nodesWithProperty("amenity", equal: "cinema").count, 1)
    }
    
    // MARK: - Ways
    
    func testParsingWays() {
        let parser = OSMElementsParser()
        parser.initialize()
        XCTAssertEqual(parser.ways.count, 108)
    }
    
    func testWaysWithProperty() {
        let parser = OSMElementsParser()
        parser.initialize()
        
        let ways = parser.waysWithProperty("name")
        XCTAssertEqual(ways.count, 16)
    }
    
    func testNodesOfWay() {
        let parser = OSMElementsParser()
        parser.initialize()
        
        XCTAssertEqual(parser.ways[0].nodes.count, 3)
    }
}
