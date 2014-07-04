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

    class func createTableTiles() {
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS tiles (id INTEGER PRIMARY KEY, x DOUBLE, y DOUBLE, zoom INTEGER)", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func createTableNodes() {
        var db = FMDatabase(path: pathToDB)
        if db.open() {
            db.executeUpdate("CREATE TABLE IF NOT EXISTS nodes (id INTEGER PRIMARY KEY, tile_id INTEGER, latitude DOUBLE, longitude DOUBLE, user TEXT)", withArgumentsInArray: [])
            db.close()
        }
    }
    
    class func saveNodes(nodes:Array<OSMNode>, forTileId tileId:Int) {
        var db = FMDatabase(path: pathToDB)
        if !db.open() {
            return
        }
        
        db.beginTransaction()
        for node in nodes {
            db.executeUpdate("INSERT INTO nodes (tile_id, latitude, longitude, user) VALUES (?, ?, ?, ?)", withArgumentsInArray: [tileId, node.location.coordinate.latitude, node.location.coordinate.longitude, node.user])
        }
        db.commit()
        db.close()
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
}
