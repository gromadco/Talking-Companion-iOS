//
//  PlacesListTableViewController.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 24.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

class PlacesListTableViewController: UITableViewController {

    // MARK: - Properties
    
    var nodes:Array<OSMNode> = Array()
    var ways:Array<OSMWay> = Array()
    
    // MARK: - View
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        var nibName = UINib(nibName: "PlaceTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "PlaceTableViewCell")
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
