//
//  SQLAccess.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 03.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

let pathToDB = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("db.sqlite")

class SQLAccess: NSObject {

    // MARK: - Nodes
    
    class func createTableNodes() {
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS nodes (uid INTEGER UNIQUE, tile_id INTEGER, announced_date DOUBLE,  latitude DOUBLE, longitude DOUBLE, user TEXT, name TEXT, amenity TEXT, shop TEXT, operator TEXT)", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func saveNodes(nodes:[OSMNode], forTileId tileId:Int) {
        var db = FMDatabase(path: pathToDB)
        if !db.open() {
            return
        }
        
        db.beginTransaction()
        for node in nodes {
            var name = ""
            var amenity = "", shop = "", operatorName = ""
            
            if let nodeName = node.name? {
                name = nodeName
            }
            else {
                continue
            }
            
            if let nodeAmenity = node.amenity? {
                amenity = nodeAmenity
            }
            if let nodeShop = node.shop? {
                shop = nodeShop
            }

            if let nodeOperator = node.operatorName? {
                operatorName = nodeOperator
            }

            
            
            db.executeUpdate("INSERT OR IGNORE INTO nodes (uid, tile_id, latitude, longitude, user, name, amenity, shop, operator) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsInArray: [node.uid, tileId, node.location.coordinate.latitude, node.location.coordinate.longitude, node.user, name, amenity, shop, operatorName])
        }
        db.commit()
        db.close()
    }

    class func nodes() -> [OSMNode] {
        var nodes = [OSMNode]()
        
        var db = FMDatabase(path: pathToDB)
        if !db.open() {
            return nodes
        }
        
        var result = db.executeQuery("SELECT * FROM nodes", withArgumentsInArray: [])
        while result.next() {
            nodes.append(SQLAccess.nodeFromResult(result))
        }
        
        db.close()
        return nodes
    }
    
    class func nodesForTile(tile:OSMTile) -> [OSMNode]  {
        var nodes = [OSMNode]()
        
        var db = FMDatabase(path: pathToDB)
        if !db.open() {
            return nodes
        }

        var result = db.executeQuery("SELECT * FROM ((SELECT id AS tileid FROM tiles WHERE x = ? AND y = ? AND zoom = ?) JOIN nodes) WHERE name <> '' AND nodes.tile_id = tileid", withArgumentsInArray:[tile.x, tile.y, tile.zoom])
        while result.next() {
            nodes.append(SQLAccess.nodeFromResult(result))
        }
        
        db.close()
        return nodes;
    }
    
    class func updateNode(node:OSMNode) {
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("UPDATE nodes SET announced_date = ? WHERE uid = ?", withArgumentsInArray: [node.announcedDate!, node.uid])
            db.close()
        }
    }
    
    class func nodeFromResult(result:FMResultSet) -> OSMNode {
        var uid = Int(result.intForColumn("uid"))
        var announcedDate = result.dateForColumn("announced_date")
        var latitude = result.doubleForColumn("latitude")
        var longitude = result.doubleForColumn("longitude")
        var user = result.stringForColumn("user")

        var node = OSMNode(uid:uid, latitude: latitude, longitude: longitude, user: "user")
        node.uid = uid
        node.name = result.stringForColumn("name")
        node.announcedDate = announcedDate
        node.amenity = result.stringForColumn("amenity")
        node.shop = result.stringForColumn("shop")
        node.operatorName = result.stringForColumn("operator")
        
        return node;
    }

    // MARK: - Tiles

    class func createTableTiles() {
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS tiles (id INTEGER PRIMARY KEY, x INTEGER, y INTEGER, zoom INTEGER)", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func saveTile(tile:OSMTile) -> Int {
        var lastId:Int = 0
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("INSERT INTO tiles (x, y, zoom) VALUES (?, ?, ?)", withArgumentsInArray: [tile.x, tile.y, tile.zoom])
            lastId = Int(db.lastInsertRowId())
            db.close()
        }
        
        return lastId
    }

    class func hasTile(tile:OSMTile) -> Bool {
        var db = FMDatabase(path: pathToDB)
        var has = false
        
        if db.open() {
            var result = db.executeQuery("SELECT count(*) as count FROM tiles WHERE x = ? AND y = ? AND zoom = ?", withArgumentsInArray: [tile.x, tile.y, tile.zoom])
            if result.next() && result.intForColumn("count") > 0 {
                has = true
            }
            db.close()
        }
        return has;
    }
    
    class func tiles() -> [OSMTile] {
        var tiles = [OSMTile]()
        
        var db = FMDatabase(path: pathToDB)
        if !db.open() {
            return tiles
        }
        
        var result = db.executeQuery("SELECT * FROM tiles", withArgumentsInArray: [])
        while result.next() {
            var uid = Int(result.intForColumn("id"))
            var x = Int(result.intForColumn("x"))
            var y = Int(result.intForColumn("y"))
            var zoom = Int(result.intForColumn("zoom"))
        
            var tile = OSMTile(x: x, y: y, zoom: zoom)
            tile.uid = uid
            tiles.append(tile)
        }
        
        db.close()
        return tiles
    }
}
