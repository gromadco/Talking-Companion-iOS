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

class OSMElementsParser: NSObject {
    
    // MARK: - Properties
    
    var nodes:Array<OSMNode> = Array()
    var ways:Array<OSMWay> = Array()
    
    // MARK: - Initializing
    
    func initialize() {
        nodes = parseNodes()
        ways = parseWays()
    }
    
    // MARK: - Parsing
    
    func parser() -> AnyObject {
        var filePath = NSBundle.mainBundle().pathForResource("map", ofType:"osm")
        var data = NSData(contentsOfFile:filePath)
        var xml = NSString(data: data, encoding: NSUTF8StringEncoding)
        var parser = SMXMLDocument(data: data, error: nil)
        
        return parser
    }
    
    func parseNodes() -> Array<OSMNode> {
        let parser:SMXMLDocument = self.parser() as SMXMLDocument
        
        var node:OSMNode
        var nodes:Array<OSMNode> = Array()
        var nodesXML = parser.childrenNamed("node");
        
        for nodeXML:AnyObject in nodesXML {
            var element:SMXMLElement = nodeXML as SMXMLElement
            
            // required properties
            var lat = element.attributeNamed("lat").doubleValue
            var lon = element.attributeNamed("lon").doubleValue
            var user = element.attributeNamed("user")
            node = OSMNode(latitude: lat, longitude: lon, user:user)
            
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
    
    func parseWays() -> Array<OSMWay> {
        let parser:SMXMLDocument = self.parser() as SMXMLDocument
        
        var way:OSMWay
        var ways:Array<OSMWay> = Array()
        var waysXML = parser.childrenNamed("way");
        //
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
    
    func nodesWithProperty(property:String) -> Array<OSMNode> {
        var tmpNodes:Array<OSMNode> = Array()
        
        for node in nodes {
            if node.valueForKey(property) {
                tmpNodes.append(node)
            }
        }
        
        return tmpNodes
    }
    
    func waysWithProperty(property:String) -> Array<OSMWay> {
        var tmpWays:Array<OSMWay> = Array()
        
        for way in ways {
            if way.valueForKey(property) {
                tmpWays.append(way)
            }
        }
        
        return tmpWays
    }
    
    func showWaysWithProperty(property:String, equal:String) -> Array<OSMWay> {
        var tmpWays:Array<OSMWay> = Array()
        
        for way in ways {
            if let value : AnyObject = way.valueForKey(property)  {
                if value as NSString == equal {
                    tmpWays.append(way)
                }
            }
        }
        
        return tmpWays
    }

    
}
