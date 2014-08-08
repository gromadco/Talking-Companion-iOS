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
    
    init(filePath:String)  {
        self.xmlData = NSData(contentsOfFile:filePath)
        //self.initializingElements()
    }
    
    init(xmlData:NSData) {
        self.xmlData = xmlData
        //self.initializingElements()
    }
    
    func initializingElements() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.nodes = self.parseNodes()
            //ways = parseWays()
        }
    }
    
    func parseWithComplitionHandler(handler:(nodes:[OSMNode], ways:[OSMWay]) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.nodes = self.parseNodes()
            self.ways = self.parseWays()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                handler(nodes:self.nodes, ways:self.ways)
            }
        }
    }
    
    // MARK: - Parsing
    
    func parser() -> AnyObject {
        return SMXMLDocument(data: xmlData, error: nil)
    }
    
    func parseNodes() -> [OSMNode] {
        let parser:SMXMLDocument = self.parser() as SMXMLDocument
        var nodes = [OSMNode]()
        
        let nodesXML = parser.childrenNamed("node")
        if let _ = nodesXML {}
        else { return [OSMNode]() }
    
        NSLog("start parsing with count of nodes: \(nodesXML.count)")
        
        for nodeXML:AnyObject in nodesXML {
            let element:SMXMLElement = nodeXML as SMXMLElement
            
            // required properties
            let uid:Int = element.attributeNamed("uid").toInt()!
            let lat = element.attributeNamed("lat").doubleValue
            let lon = element.attributeNamed("lon").doubleValue
            let user = element.attributeNamed("user")
            var node = OSMNode(uid:uid, latitude: lat, longitude: lon, user:user)
        
            // check tags
            if let tagsXML = element.childrenNamed("tag") {
                for tagXML:AnyObject in tagsXML {
                    let tagElement = tagXML as SMXMLElement
                    
                    if tagElement.attributeNamed("k") == "amenity" {
                        node.amenity = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "name" {
                        node.name = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "operator" {
                        node.operatorName = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "shop" {
                        node.shop = tagElement.attributeNamed("v")
                    }
                }
            }
            
            nodes.append(node)
        }
        return nodes;
    }
    
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
            let user = element.attributeNamed("user")
            var way = OSMWay(wayId: wayId, user: user)
            
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
    
    // MARK: -
    
    func nodesWithProperty(property:String) -> [OSMNode] {
        var tmpNodes = [OSMNode]()
        
        for node in nodes {
            if node.valueForKey(property) {
                tmpNodes.append(node)
            }
        }
        
        return tmpNodes
    }
    
    func nodesWithProperty(property:String, equal:String) -> [OSMNode] {
        var tmpNodes = [OSMNode]()
        
        for node in nodes {
            if let value : AnyObject = node.valueForKey(property)  {
                if value as NSString == equal {
                    tmpNodes.append(node)
                }
            }
        }
        
        return tmpNodes
    }
    
    func waysWithProperty(property:String) -> [OSMWay] {
        var tmpWays = [OSMWay]()
        
        for way in ways {
            if way.valueForKey(property) {
                tmpWays.append(way)
            }
        }
        
        return tmpWays
    }
}
