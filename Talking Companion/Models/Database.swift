//
//  Database.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 03.07.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

// TODO: rename class

let pathToDB = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("db.sqlite")
let typesSeparator = ", "
let keyValueSeparator = "="

class Database: NSObject {

    // MARK: - Nodes
    
    class func createTableNodes() {
        let db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS nodes (uid TEXT UNIQUE, tile_id INTEGER, announced_date DOUBLE, latitude DOUBLE, longitude DOUBLE, name TEXT, types TEXT)", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func saveNodes(nodes:[OSMNode], forTileId tileId:Int) {
        let db = FMDatabase(path: pathToDB)
        if !db.open() {
            return
        }
        
        db.beginTransaction()
        for node in nodes {
            // convert types to string
            var typesString = ""
            for (key, value) in node.types {
                typesString += "\(key)=\(value)\(typesSeparator)"
            }
            
            db.executeUpdate("INSERT OR IGNORE INTO nodes (uid, tile_id, latitude, longitude, name, types) VALUES (?, ?, ?, ?, ?, ?)", withArgumentsInArray: [node.uid, tileId, node.location.coordinate.latitude, node.location.coordinate.longitude, node.name!, typesString])
        }
        db.commit()
        db.close()
    }
    
    class func nodesForTile(tile:OSMTile) -> [OSMNode]  {
        var nodes = [OSMNode]()
        
        let db = FMDatabase(path: pathToDB)
        if !db.open() {
            return nodes
        }

        let result = db.executeQuery("SELECT * FROM ((SELECT id AS tileid FROM tiles WHERE x = ? AND y = ? AND zoom = ?) JOIN nodes) WHERE name <> '' AND nodes.tile_id = tileid", withArgumentsInArray:[tile.x, tile.y, tile.zoom])
        while result.next() {
            nodes.append(Database.nodeFromResult(result))
        }
        
        db.close()
        return nodes
    }
    
    class func updateNode(node:OSMNode) {
        let db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("UPDATE nodes SET announced_date = ? WHERE uid = ?", withArgumentsInArray: [node.announcedDate!, node.uid])
            db.close()
        }
    }
    
    class func nodeFromResult(result:FMResultSet) -> OSMNode {
        // required properties
        let uid = result.stringForColumn("uid")
        let announcedDate = result.dateForColumn("announced_date")
        let latitude = result.doubleForColumn("latitude")
        let longitude = result.doubleForColumn("longitude")
        
        // types
        var types = [String:String]()
        let typesString = result.stringForColumn("types")
        let components = typesString.componentsSeparatedByString(typesSeparator)
        
        for component in components {
            let type = component.componentsSeparatedByString("=")
            let key = type.first!
            let value = type.last!
            if count(value) > 0 {
                types[key] = value
            }
        }

        var node = OSMNode(uid:uid, latitude: latitude, longitude: longitude)
        node.name = result.stringForColumn("name")
        node.announcedDate = announcedDate
        node.types = types
        
        return node
    }

    // MARK: - Tiles

    class func createTableTiles() {
        let db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS tiles (id INTEGER PRIMARY KEY, x INTEGER, y INTEGER, zoom INTEGER, UNIQUE (x, y, zoom))", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func saveTile(tile:OSMTile) -> Int {
        var lastId:Int = 0
        let db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("INSERT OR IGNORE INTO tiles (x, y, zoom) VALUES (?, ?, ?)", withArgumentsInArray: [tile.x, tile.y, tile.zoom])
            lastId = Int(db.lastInsertRowId())
            db.close()
        }
        
        return lastId
    }

    class func hasTile(tile:OSMTile) -> Bool {
        let db = FMDatabase(path: pathToDB)
        var has = false
        
        if db.open() {
            let result = db.executeQuery("SELECT count(*) as count FROM tiles WHERE x = ? AND y = ? AND zoom = ?", withArgumentsInArray: [tile.x, tile.y, tile.zoom])
            if result.next() && result.intForColumn("count") > 0 {
                has = true
            }
            db.close()
        }
        return has
    }
    
    class func idOfTile(tile:OSMTile) -> Int {
        let db = FMDatabase(path: pathToDB)
        var uid = 0
        
        if db.open() {
            let result = db.executeQuery("SELECT id FROM tiles WHERE x = ? AND y = ? AND zoom = ?", withArgumentsInArray: [tile.x, tile.y, tile.zoom])
            result.next()
            uid = Int(result.intForColumn("id"))
            db.close()
        }
        return uid
    }
    
    class func tiles() -> [OSMTile] {
        var tiles = [OSMTile]()
        
        let db = FMDatabase(path: pathToDB)
        if !db.open() {
            return tiles
        }
        
        let result = db.executeQuery("SELECT * FROM tiles", withArgumentsInArray: [])
        while result.next() {
            let uid = Int(result.intForColumn("id"))
            let x = Int(result.intForColumn("x"))
            let y = Int(result.intForColumn("y"))
            let zoom = Int(result.intForColumn("zoom"))
        
            var tile = OSMTile(x: x, y: y, zoom: zoom)
            tile.uid = uid
            tiles.append(tile)
        }
        
        db.close()
        return tiles
    }
}
