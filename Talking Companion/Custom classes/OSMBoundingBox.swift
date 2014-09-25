//
//  OSMBoundingBox.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 02.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

/// A bounding box for downloading contains OSM elements.
class OSMBoundingBox: NSObject, Equatable {
    let north:Double
    let south:Double
    let east:Double
    let west:Double
    
    var url:String {
        return "\(OSMBoundingBoxURL)\(west),\(south),\(east),\(north)"
    }
    
    init(tile:OSMTile) {
        north = OSMTile.tiley2latitude(y: tile.y, zoom: tile.zoom)
        south = OSMTile.tiley2latitude(y: tile.y+1, zoom: tile.zoom)
        west = OSMTile.tilex2longitude(x: tile.x, zoom: tile.zoom)
        east = OSMTile.tilex2longitude(x: tile.x+1, zoom: tile.zoom)
    }
    
    override func isEqual(object: AnyObject!) -> Bool {
        if let box = object as? OSMBoundingBox {
            return self == box
        }
        return false
    }
}

func == (lhs: OSMBoundingBox, rhs: OSMBoundingBox) -> Bool {
    return lhs.north == rhs.north && lhs.south == rhs.south && lhs.east == rhs.east && lhs.west == rhs.west
}
