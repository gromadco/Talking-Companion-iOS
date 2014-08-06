//
//  OSMBoundingBox.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 02.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

// bounding box for downloading contains OSM elements
class OSMBoundingBox: NSObject {
    var north:Double
    var south:Double
    var east:Double
    var west:Double
    
    var url:String {
        return "http://api.openstreetmap.org/api/0.6/map?bbox=\(west),\(south),\(east),\(north)"
    }
    
    init(tile:OSMTile) {
        north = OSMTile.tiley2latitude(y: tile.y, zoom: tile.zoom)
        south = OSMTile.tiley2latitude(y: tile.y+1, zoom: tile.zoom)
        west = OSMTile.tilex2longitude(x: tile.x, zoom: tile.zoom)
        east = OSMTile.tilex2longitude(x: tile.x+1, zoom: tile.zoom)
    }
    
    override func isEqual(object: AnyObject!) -> Bool {
        if let box = object as? OSMBoundingBox {
            return north == box.north && south == box.south && east == box.east && west == box.west
        }
        
        return false
    }
}