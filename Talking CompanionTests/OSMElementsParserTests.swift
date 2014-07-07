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
        XCTFail("Not implemented")
    }
    
    func testParseEmpyFile() {
        XCTFail("Not implemented")
    }
    
    func testParseIncorrectFilePath() {
        XCTFail("Not implemented")
    }
    
    // MARK: - Nodes
    
    func testParsingNodes() {
        let parser = OSMElementsParser()
        parser.initialize()
        XCTAssertEqual(parser.nodes.count, 886)
    }
    
    func testNodesWithProperty() {
        XCTFail("Not implemented")
    }
    
    func testNodeWithCurrentProperty() {
        XCTFail("Not implemented")
    }
    
    func testNodesWithManyProperties() {
        XCTFail("Not implemented")
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
        XCTFail("Not implemented")
    }
}
