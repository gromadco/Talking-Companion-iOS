//
//  GEOJSONParser.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 8/11/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class GEOJSONParser: NSObject {
    
    private let jsonData:NSData
    
    init (jsonData:NSData) {
        self.jsonData = jsonData
        
    }
    
    func parseWithComplitionHandler(handler:(nodes:[OSMNode], error:NSError?) -> Void) {
        var error:NSError?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let json = JSONValue(self.jsonData as NSData!)
            var nodes = [OSMNode]()
            
            if let features = json["features"].array {
                for feature in features {
                    // required properties
                    let coordinates = feature["geometry"]["coordinates"]
                    let latitude = coordinates[1].double!
                    let longitude = coordinates[0].double!
                    let uid = feature["id"].string!
                    
                    var node = OSMNode(uid: uid, latitude: latitude, longitude: longitude)
                    node.name = feature["properties"]["name"].string
                    
                    // optional properties
                    if let amenity = feature["properties"]["tags"]["amenity"].string {
                        node.amenity = amenity
                    }
                    if let operatorName = feature["properties"]["tags"]["operator"].string {
                        node.operatorName = operatorName
                    }
                    if let shop = feature["properties"]["tags"]["shop"].string {
                        node.shop = shop
                    }
                    
                    nodes.append(node)
                }
            }
            else {
                error = NSError(domain: "incorrect json data", code: 1, userInfo: nil)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(nodes: nodes, error: error)
            }
        }
    }
}
