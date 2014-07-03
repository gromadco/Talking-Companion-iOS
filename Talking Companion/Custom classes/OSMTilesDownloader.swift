//
//  OSMTilesDownloader.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 02.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class OSMTilesDownloader: NSObject {
   
    func downloadNeighboringTilesFor(tile centerTile:OSMTile) {
        var tiles:Array<OSMTile> = centerTile.neighboringTiles()
        
        for (index, tile) in enumerate(tiles) {
            // if tile not exist in db then ..., else to next tile
            var box = OSMBoundingBox(tile: tile)
            
            // download .osm
            var request = NSURLRequest(URL: NSURL(string: box.url))
            var operation = AFHTTPRequestOperation(request: request)
            var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            path += "/map\(index).osm"
            operation.outputStream = NSOutputStream(toFileAtPath: path, append: false)

            operation.setCompletionBlockWithSuccess({ (_, responseObject) in
                    var parser = OSMElementsParser()
                    parser.filePath = path
                    parser.initialize()
                },
                failure: { [unowned self] (_, error) in })
            operation.start()
        }
    }
}
