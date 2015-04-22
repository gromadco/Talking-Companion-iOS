//
//  OSMTileTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 05.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import XCTest

let coordinatesThreshold = 0.000001
let deltasThreshold = 0.00000000001

class OSMTileTests: XCTestCase {
    
    func testInitCoordinate() {
        let tile = OSMTile(latitude: 37.446338, longitude: -122.160744, zoom: 16)
        XCTAssertEqual(tile.x, 10529)
        XCTAssertEqual(tile.y, 25406)
        XCTAssertEqual(tile.zoom, 16)
    }
    
    func testInitXYZ() {
        let tile = OSMTile(x: 10529, y: 25406, zoom: 16)
        XCTAssertEqual(tile.x, 10529)
        XCTAssertEqual(tile.y, 25406)
        XCTAssertEqual(tile.zoom, 16)
    }
    
    func testUrl() {
        let tile = OSMTile(x: 39584, y: 25406, zoom: 16)
        XCTAssertEqual(tile.url, "http://tile.openstreetmap.org/16/39584/25406.png")
    }
    
    func testToCoordinates() {
        let tile = OSMTile(x: 10529, y: 25406, zoom: 16)
        
        XCTAssertLessThanOrEqual(abs(tile.toCoordinates().latitude - 37.4486965859104), coordinatesThreshold)
        XCTAssertLessThanOrEqual(abs(tile.toCoordinates().longitude - -122.162475585938), coordinatesThreshold)
    }
    
    func testDelates() {
        let tile = OSMTile(x: 39584, y: 25406, zoom: 16)
        
        XCTAssertLessThanOrEqual(abs(tile.deltas().latitude - 0.00436113971004914), coordinatesThreshold)
        XCTAssertLessThanOrEqual(abs(tile.deltas().longitude - 0.0054931640625), coordinatesThreshold)
    }
    
    func testNeighboringTiles() {
        let tile = OSMTile(x: 39584, y: 25406, zoom: 16)
        let neighboringTiles = tile.neighboringTiles()
        let neighboringTilesSet = Set(neighboringTiles)


        XCTAssert(neighboringTilesSet.contains(OSMTile(x: 39583, y: 25406, zoom: 16)))
        XCTAssert(neighboringTilesSet.contains(OSMTile(x: 39584, y: 25406, zoom: 16)))
        XCTAssert(neighboringTilesSet.contains(OSMTile(x: 39583, y: 25405, zoom: 16)))
        XCTAssert(neighboringTilesSet.contains(OSMTile(x: 39584, y: 25405, zoom: 16)))
    }
    
    func testBoundingBox() {
        let tile = OSMTile(x: 39584, y: 25406, zoom: 16)
        let box = OSMBoundingBox(tile: tile)
        
        XCTAssertEqual(tile.toBoundingBox(), box)
    }
    
    func testTileYToLatitude() {
        XCTAssertLessThanOrEqual(abs(OSMTile.tiley2latitude(y: 25406, zoom: 16) - 37.4486965859104), coordinatesThreshold)
    }
    
    func testTileXToLongitude() {
        XCTAssertLessThanOrEqual(abs(OSMTile.tilex2longitude(x: 10529, zoom: 16) - -122.162475585938), coordinatesThreshold)
    }
}
