//
//  OSMTile.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 01.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectiveC

class OSMTile: Equatable, Hashable {
    var uid:Int?
    let x:Int
    let y:Int
    let zoom:Int
    var url:String { return "\(OSMTileURL)\(zoom)/\(x)/\(y).png" }
    var hashValue: Int { return "\(x):\(y):\(zoom)".hashValue }
   
    init(x:Int, y:Int, zoom:Int) {
        self.x = x
        self.y = y
        self.zoom = zoom
    }
    
    init(latitude:Double, longitude:Double, zoom:Int) {
        self.zoom = zoom
        self.x = Int(((longitude + 180.0) / 360.0 * pow(2.0, CDouble(self.zoom))))
        self.y = Int(floor((1.0 - log( tan(latitude * M_PI/180.0) + 1.0 / cos(latitude * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, CDouble(self.zoom))))
    }
    
    func toCoordinates() -> CLLocationCoordinate2D {
        let latitude = OSMTile.tiley2latitude(y: y, zoom: zoom)
        let longitude = OSMTile.tilex2longitude(x: x, zoom: zoom)
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    // width and height of OSMTile
    func deltas() -> CLLocationCoordinate2D {
        let neighboringTile = OSMTile(x: self.x+1, y: self.y+1, zoom: zoom)
        let neighboringCoordinates = neighboringTile.toCoordinates()
        let deltaLatitude:Double = abs(neighboringCoordinates.latitude - self.toCoordinates().latitude)
        let deltaLongitude:Double = abs(neighboringCoordinates.longitude - self.toCoordinates().longitude)
        
        return CLLocationCoordinate2DMake(deltaLatitude, deltaLongitude)
    }
    
    //  square 3x3, center - current location
    func neighboringTiles() -> Array<OSMTile> {
        let deltas = self.deltas()
        let center = self.toCoordinates()
        
        let leftTop = OSMTile(latitude: center.latitude + deltas.latitude/4, longitude: center.longitude - deltas.longitude/4, zoom: zoom)
        let leftMiddle = OSMTile(latitude: center.latitude, longitude: center.longitude - deltas.longitude/4, zoom: zoom)
        let leftBottom = OSMTile(latitude: center.latitude - deltas.latitude/4, longitude: center.longitude - deltas.longitude/4, zoom: zoom)
        
        let centerTop = OSMTile(latitude: center.latitude + deltas.latitude/4, longitude: center.longitude, zoom: zoom)
        let centerBottom = OSMTile(latitude: center.latitude - deltas.latitude/4, longitude: center.longitude, zoom: zoom)

        let rightTop = OSMTile(latitude: center.latitude + deltas.latitude/4, longitude: center.longitude + deltas.longitude/4, zoom: zoom)
        let rightMiddle = OSMTile(latitude: center.latitude, longitude: center.longitude + deltas.longitude/4, zoom: zoom)
        let rightBottom = OSMTile(latitude: center.latitude + deltas.latitude/4, longitude: center.longitude - deltas.longitude/4, zoom: zoom)
        
        let set = NSMutableSet(array: [self, leftTop, leftMiddle, leftBottom, centerTop, centerBottom, rightTop, rightMiddle, rightBottom])
        let tiles:[OSMTile] = set.allObjects as! [OSMTile]
        return tiles
    }
    
    func toBoundingBox() -> OSMBoundingBox {
        return OSMBoundingBox(tile: self)
    }

    // MARK: - Converting
    
    class func tiley2latitude(#y:Int, zoom:Int) -> Double {
        let n = M_PI - Double(y) * 2.0 * M_PI / pow(2.0, CDouble(zoom))
        let latitude = 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)))
        return latitude
    }
    class func tilex2longitude(#x:Int, zoom:Int) -> Double {
        let longitude = Double(x) / pow(2.0, CDouble(zoom)) * 360.0 - 180.0
        return longitude
    }
    
    // MARK: - NSObject methods
    
    func description() -> String {
        return "(\(x); \(y); \(zoom))"
    }

}

func ==(lhs: OSMTile, rhs: OSMTile) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.zoom == rhs.zoom
}
