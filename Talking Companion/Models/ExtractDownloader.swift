//
//  ExctractDownloader.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 8/8/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

@objc protocol ExtractDownloaderDelegate:NSObjectProtocol {
    func extractDownloaderFinished(nodes:[OSMNode])
    func extractDownloaderFailed(error:NSError)
}

class ExtractDownloader: NSObject {
   
    let delegate:ExtractDownloaderDelegate
    
    init(delegate:ExtractDownloaderDelegate) {
        self.delegate = delegate
    }
    
    func downloadCity(city:String) {
        let urlString = "\(OSMExtractURL)\(city)\(OSMExtractFormat)"
    
        // downloading extract
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        var operation = AFHTTPRequestOperation(request: request)
        operation.setCompletionBlockWithSuccess({ (_, responseObject) in
            NSLog("extract downloaded")
            
            let compressedData = responseObject as NSData
            let uncompressedData = compressedData.bunzip2()
            self.parseXMLFromString(uncompressedData)
        },
        failure: { [unowned self] (_, error) in })
        operation.start()
    }
    
    func downloadExtractForCity(city:String) {
        let urlString = "\(JSONExtractURL)\(city)\(JSONExtractFormat)"
        
        // downloading extract
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        var operation = AFHTTPRequestOperation(request: request)
        operation.setCompletionBlockWithSuccess({ (_, responseObject) in
            NSLog("JSON Extract: extract downloaded")
            let compressedData = responseObject as NSData
            let uncompressedData = compressedData.bunzip2()
            self.parseJSONFromString(uncompressedData)
        },
        failure: { [unowned self] (_, error) in
            NSLog("JSON Extract: \(error)")
        })
        operation.start()
    }
    
    func parseXMLFromString(xmlData:NSData) {
        let parser = OSMElementsParser(xmlData: xmlData)
        parser.parseWithComplitionHandler() { nodes, _ in
            self.delegate.extractDownloaderFinished(nodes)
        };
    }
    
    func parseJSONFromString(jsonData:NSData) {
        NSLog("JSON Extract: parsing started")
        
        let jsonParser = GEOJSONParser(jsonData: jsonData)
        jsonParser.parseWithComplitionHandler() { nodes, error in
            if error != nil {
                NSLog("JSON Extract: parsing failed \(error)")
                self.delegate.extractDownloaderFailed(error!)
                return
            }
            
            for node in nodes {
                let tile = OSMTile(latitude: node.location.coordinate.latitude, longitude: node.location.coordinate.longitude, zoom: 16)
                var tileId = SQLAccess.saveTile(tile)
                if tileId == 0 {
                    tileId = SQLAccess.idOfTile(tile)
                }
                SQLAccess.saveNodes([node], forTileId: tileId)
            }
            NSLog("JSON Extract: parsing finished - \(nodes.count) nodes")
            self.delegate.extractDownloaderFinished(nodes)
        }
    }
}
