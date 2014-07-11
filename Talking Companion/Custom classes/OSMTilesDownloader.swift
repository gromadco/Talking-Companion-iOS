//
//  OSMTilesDownloader.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 02.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

@objc protocol OSMTilesDownloaderDelegate {
    func tilesDownloaded();
}

class OSMTilesDownloader: NSObject {
   
    var leftDownloading = 0
    var delegate:OSMTilesDownloaderDelegate?
    
    func downloadNeighboringTilesFor(tile centerTile:OSMTile) {
        var tiles:Array<OSMTile> = centerTile.neighboringTiles()
        
        for (index, tile) in enumerate(tiles) {
            if SQLAccess.hasTile(tile) {
                continue
            }
            
            var box = OSMBoundingBox(tile: tile)
            
            // downloading .osm
            var request = NSURLRequest(URL: NSURL(string: box.url))
            var operation = AFHTTPRequestOperation(request: request)
            var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            path += "/map\(index).osm"
            operation.outputStream = NSOutputStream(toFileAtPath: path, append: false)

            operation.setCompletionBlockWithSuccess({ (_, responseObject) in
                println("tile \(tile) downloaded")
                var parser = OSMElementsParser(filePath: path)
                var tileId = SQLAccess.saveTile(tile)
                SQLAccess.saveNodes(parser.nodes, forTileId: tileId)
                
                self.leftDownloading--;
                if self.leftDownloading == 0 {
                    self.delegate?.tilesDownloaded()
                }
            
                },
                failure: { [unowned self] (_, error) in })
            println("start downloading @ \(box.url)")
            operation.start()
            leftDownloading++;
        }
        if self.leftDownloading == 0 {
            self.delegate?.tilesDownloaded()
        }
    }
}
