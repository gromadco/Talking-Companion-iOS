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

    var nodes:OSMNode[] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nibName = UINib(nibName: "PlaceTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "PlaceTableViewCell")
        
        self.startParse()
        self.tableView.reloadData()
    }

    func startParse() {
        var filePath = NSBundle.mainBundle().pathForResource("map", ofType:"osm")
        var data = NSData(contentsOfFile:filePath)
        var xml = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        var error:NSErrorPointer?
        var parser = SMXMLDocument(data: data, error: error!)

        var node:OSMNode
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
    }
    
    // MARK: - Table view data source
    
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
