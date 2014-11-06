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
    
    init(delegate:OSMTilesDownloaderDelegate?) {
        self.delegate = delegate
    }
    
    func downloadNeighboringTilesFor(tile centerTile:OSMTile) {
        let tiles:Array<OSMTile> = centerTile.neighboringTiles()
        
        for (index, tile) in enumerate(tiles) {
            if Database.hasTile(tile) {
                continue
            }
            
            let box = OSMBoundingBox(tile: tile)
            
            // downloading .osm
            let request = NSURLRequest(URL: NSURL(string: box.url)!)
            let operation = AFHTTPRequestOperation(request: request)
            var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            path += "/map\(index).osm"
            operation.outputStream = NSOutputStream(toFileAtPath: path, append: false)

            operation.setCompletionBlockWithSuccess({ (_, responseObject) in
                NSLog("tile \(tile) downloaded")
                
                let tileId = Database.saveTile(tile)
                let parser = OSMElementsParser(filePath: path)
                parser.parseWithComplitionHandler() { nodes, _ in
                    Database.saveNodes(parser.nodes, forTileId: tileId)
                };
                
                self.leftDownloading--;
                if self.leftDownloading == 0 {
                    self.delegate?.tilesDownloaded()
                }
            },
            failure: { [unowned self] (_, error) in
                NSLog("tile downloading failed")
            })
            
            NSLog("start downloading @ \(box.url)")
            operation.start()
            leftDownloading++;
        }
        
        // all tiles already downloaded
        if self.leftDownloading == 0 {
            self.delegate?.tilesDownloaded()
        }
    }
}
