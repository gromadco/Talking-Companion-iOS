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
    var filePath:String
    
    // MARK: - Initializing
    
    init(filePath:String)  {
        self.filePath = filePath
        nodes = parseNodes()
        ways = parseWays()
    }
        
    // MARK: - Parsing
    
    func parser() -> AnyObject {
        var data = NSData(contentsOfFile:filePath)
        var xml = NSString(data: data, encoding: NSUTF8StringEncoding)
        var parser = SMXMLDocument(data: data, error: nil)
        
        return parser
    }
    
    func parseNodes() -> [OSMNode] {
        let parser:SMXMLDocument = self.parser() as SMXMLDocument
        
        var node:OSMNode
        var nodes = [OSMNode]()
        var nodesXML = parser.childrenNamed("node")
        
        if nodesXML? == nil {
            return [OSMNode]()
        }
    
        println("start parsing with count of nodes: \(nodesXML.count)")
        
        for nodeXML:AnyObject in nodesXML {
            var element:SMXMLElement = nodeXML as SMXMLElement
            
            // required properties
            var uid:Int = element.attributeNamed("uid").toInt()!
            var lat = element.attributeNamed("lat").doubleValue
            var lon = element.attributeNamed("lon").doubleValue
            var user = element.attributeNamed("user")
            node = OSMNode(uid:uid, latitude: lat, longitude: lon, user:user)
        
            // check tags
            if let tagsXML = element.childrenNamed("tag") {
                for tagXML:AnyObject in tagsXML {
                    var tagElement = tagXML as SMXMLElement
                    
                    if tagElement.attributeNamed("k") == "amenity" {
                        node.amenity = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "name" {
                        node.name = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "operator" {
                        node.operator = tagElement.attributeNamed("v")
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
        
        var way:OSMWay
        var ways = [OSMWay]()
        var waysXML = parser.childrenNamed("way");
        
        
        if waysXML? == nil {
            return [OSMWay]()
        }
        
        for wayXML:AnyObject in waysXML {
            var element:SMXMLElement = wayXML as SMXMLElement
            
            // required properties
            var wayId = element.attributeNamed("id")
            var user = element.attributeNamed("user")
            way = OSMWay(wayId: wayId, user: user)
            
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
