//
//  GEOJSONParser.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 8/11/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class GEOJSONParser: NSObject {
    
    var jsonData:NSData
    
    init (jsonData:NSData) {
        self.jsonData = jsonData
    }
    
    func parseWithComplitionHandler(handler:(nodes:[OSMNode], error:NSError?) -> Void) {
        var error:NSError?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let json = JSONValue(self.jsonData)
        
            var nodes = [OSMNode]()
            
            if let features = json["features"].array {
                NSLog("total: \(features.count)")
                for feature in features {
                    let coordinates = feature["geometry"]["coordinates"]
                    let latitude = coordinates[0].double
                    let longitude = coordinates[1].double
                    //NSLog("coordinates: \(coordinates)")
                    
                    let elementDetails:[String]! = feature["id"].string?.componentsSeparatedByString("/")
                    let type = elementDetails[0]
                    let uid = elementDetails[1]
                    //NSLog("type: \(type), id: \(uid)")
                    
                    let name = feature["properties"]["name"].string
                    
                    if let amenity = feature["properties"]["tags"]["amenity"].string {
                        NSLog("node has amenity: \(amenity)")
                    }
                    if let operatorName = feature["properties"]["tags"]["operator"].string {
                        NSLog("node has operator: \(operatorName)")
                    }
                    if let shop = feature["properties"]["tags"]["shop"].string {
                        NSLog("node has shop: \(shop)")
                    }
                }
            }
            else {
                error = NSError(domain: "incorrect json data", code: 1, userInfo: nil)
            }
            
            handler(nodes: nodes, error: error)
        }
    }
}
