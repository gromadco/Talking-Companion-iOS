//
//  PlacesListTableViewController.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 24.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

extension String {
    var doubleValue: Double {
    return (self as NSString).doubleValue
    }
}

class PlacesListTableViewController: UITableViewController {

    // MARK: - Properties
    
    var nodes:Array<OSMNode> = Array()
    var ways:Array<OSMWay> = Array()
    
    // MARK: - View
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        var nibName = UINib(nibName: "PlaceTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "PlaceTableViewCell")
        
        self.nodes = self.parseNodes()
        self.ways = self.parseWays()
        
        showWaysWithProperty("name")
        //showWaysWithProperty("amenity", equal:"fast_food")
        
        self.tableView.reloadData()
    }
    
    // MARK: - Parsing
    
    func parser() -> SMXMLDocument {
        var filePath = NSBundle.mainBundle().pathForResource("map", ofType:"osm")
        var data = NSData(contentsOfFile:filePath)
        var xml = NSString(data: data, encoding: NSUTF8StringEncoding)
        var parser = SMXMLDocument(data: data, error: nil)
        
        return parser
    }

    func parseNodes() -> Array<OSMNode> {
        let parser = self.parser()

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
                    if tagElement.attributeNamed("k") == "shop" {
                        node.shop = tagElement.attributeNamed("v")
                    }
                    if tagElement.attributeNamed("k") == "operator" {
                        node.operator = tagElement.attributeNamed("v")
                    }
                }
            }
            
            nodes.append(node)
        }
        return nodes;
    }
    
    func parseWays() -> Array<OSMWay> {
        let parser = self.parser()
        
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
            
            //println(way.description())
            ways.append(way)
        }
        return ways;
    }
    
    // MARK: - Displaying
    
    func showWaysWithProperty(property:String) {
        for way in ways {
            if way.valueForKey(property) {
                println(way.description)
            }
        }
    }
    
    func showWaysWithProperty(property:String, equal:String) {
        for way in ways {
            if let value : AnyObject = way.valueForKey(property)  {
                if value as NSString == equal {
                    println(way.description)
                }
            }
        }
    }
    
    // MARK: - UITableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PlaceTableViewCell {
        let cellIdentifier = "PlaceTableViewCell"
        var cell:PlaceTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as PlaceTableViewCell
        tableView

        var currentNode:OSMNode = nodes[indexPath.row] as OSMNode
        cell.coordinateLabel.text = currentNode.coordinates()
        cell.userLabel.text = currentNode.user
    
        if let amenity = currentNode.amenity {
            cell.amenityLabel.text = amenity
        }

        return cell
    }
}
