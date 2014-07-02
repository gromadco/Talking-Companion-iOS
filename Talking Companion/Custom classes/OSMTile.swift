//
//  OSMTile.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 01.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit
import CoreLocation

class OSMTile: NSObject {
    var x:Int
    var y:Int
    var zoom:Int = 16
   
    init(x:Int, y:Int, zoom:Int) {
        self.x = x
        self.y = y
        self.zoom = zoom
    }
    
    init(latitude:Double, longitude:Double, zoom:Int) {
        self.zoom = zoom
        
        self.x = Int(((longitude + 180.0) / 360.0 * pow(2.0, CDouble(zoom))))
        self.y = Int(floor((1.0 - log( tan(latitude * M_PI/180.0) + 1.0 / cos(latitude * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, CDouble(zoom))))
    }
    
    func toCoordinates() -> CLLocationCoordinate2D {
        var n = M_PI - Double(y) * 2.0 * M_PI / pow(2.0, CDouble(zoom))
        var latitude = 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)))
        var longitude = Double(x) / pow(2.0, CDouble(zoom)) * 360.0 - 180.0
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    func deltas() -> CLLocationCoordinate2D {
        var neighboring = OSMTile(x: self.x+1, y: self.y+1, zoom: zoom)
        
        var neighboringCoordinates = neighboring.toCoordinates()
        var deltaLatitude:Double = abs(neighboringCoordinates.latitude - self.toCoordinates().latitude)
        var deltaLongitude:Double = abs(neighboringCoordinates.longitude - self.toCoordinates().longitude)
        
        return CLLocationCoordinate2DMake(deltaLatitude, deltaLongitude)
    }
    
    func link() -> String {
        return "http://tile.openstreetmap.org/\(zoom)/\(x)/\(y).png"
    }
}

/*
int long2tilex(double lon, int z)
{
    return (int)(floor((lon + 180.0) / 360.0 * pow(2.0, z)));
}

int lat2tiley(double lat, int z)
{
    return (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, z)));
}

double tilex2long(int x, int z)
{
    return x / pow(2.0, z) * 360.0 - 180;
}

double tiley2lat(int y, int z)
{
    double n = M_PI - 2.0 * M_PI * y / pow(2.0, z);
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}
*/