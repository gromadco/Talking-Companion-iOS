//
//  OSMElementsParser.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 26.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

class OSMElementsParser {
    
    // MARK: - Properties
    
    var nodes = [OSMNode]()
    var ways = [OSMWay]()
    let xmlData:NSData?
    
    // MARK: - Initializing
    
    convenience init(filePath:String)  {
        let data = NSData(contentsOfFile:filePath)!
        self.init(xmlData:data)
    }
    
    init(xmlData:NSData) {
        self.xmlData = xmlData
    }

    func parseWithComplitionHandler(handler:(nodes:[OSMNode], ways:[OSMWay]) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.nodes = self.parseNodes()
            self.ways = self.parseWays()
            dispatch_async(dispatch_get_main_queue()) {
                handler(nodes:self.nodes, ways:self.ways)
            }
        }
    }
    
    // MARK: - Parsing
    
    func parser() -> SMXMLDocument {
        return SMXMLDocument(data: xmlData, error: nil)
    }
    
    func parseNodes() -> [OSMNode] {
        let parser:SMXMLDocument = self.parser()
        var nodes = [OSMNode]()
        
        let nodesXML = parser.childrenNamed("node")
        if let _ = nodesXML {}
        else { return [OSMNode]() }
    
        NSLog("start parsing nodes: \(nodesXML.count)")
        
        for nodeXML:AnyObject in nodesXML {
            let element:SMXMLElement = nodeXML as SMXMLElement
            
            // required properties
            let uid:String = element.attributeNamed("uid")
            let lat = element.attributeNamed("lat").doubleValue
            let lon = element.attributeNamed("lon").doubleValue
            var node = OSMNode(uid:"node/\(uid)", latitude: lat, longitude: lon)
        
            // check tags
            if let tags = element.childrenNamed("tag") as? [SMXMLElement] {
                if !hasName(tags) {
                    continue
                }
                
                for tag in tags {
                    let key = tag.attributeNamed("k")
                    let value = tag.attributeNamed("v")
                    if key == "name" {
                        node.name = value
                        NSLog ("found: \(value)")
                    }
                    else {
                        node.types[key] = value
                    }
                }
                nodes.append(node)
            }
        }
        return nodes;
    }
    
    private func hasName(tags:[SMXMLElement]) -> Bool {
        for tag in tags {
            let key = tag.attributeNamed("k")
            let value = tag.attributeNamed("v")
            if key == "name" {
                return true
            }
        }
        
        return false
    }
    
    // TODO: - Change parsing like in node
    func parseWays() -> [OSMWay] {
        let parser:SMXMLDocument = self.parser() as SMXMLDocument
        var ways = [OSMWay]()
        
        let waysXML = parser.childrenNamed("way");
        if let _ = waysXML{}
        else { return [OSMWay]() }
        
        for wayXML:AnyObject in waysXML {
            let element:SMXMLElement = wayXML as SMXMLElement
            
            // required properties
            let wayId = element.attributeNamed("id")
            var way = OSMWay(wayId: wayId)
            
            // check nodes of way
            if let nodesXML = element.childrenNamed("nd") {
                for nodeXML:AnyObject in nodesXML {
                    let nodeElement = nodeXML as SMXMLElement
                    let ref = nodeElement.attributeNamed("ref")
                    way.nodes.append(ref)
                }
            }
            
            // check tags
            if let tagsXML = element.childrenNamed("tag") {
                for tagXML:AnyObject in tagsXML {
                    let tagElement = tagXML as SMXMLElement
                    
                    if tagElement.attributeNamed("k") == "amenity" {
                        way.amenity = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "building" {
                        way.building = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "name" {
                        way.name = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "shop" {
                        way.shop = tagElement.attributeNamed("v")
                    }
                }
            }
            
            ways.append(way)
        }
        return ways;
    }
}
