//
//  OSMNodeTests.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 6/1/15.
//  Copyright (c) 2015 serejahh inc. All rights reserved.
//

import Nimble
import Quick

let kNodeUid = "1"
let kNodeLatitude = 7.0
let kNodeLongitude = 13.0

class OSMNodeTests: QuickSpec {
    
    var node:OSMNode!
    
    override func spec() {
        
        beforeEach {
            self.node = OSMNode(uid:kNodeUid, latitude: kNodeLatitude, longitude: kNodeLongitude)
        }
        
        describe("A node") {
            it("can be created") {
                expect(self.node).toEventuallyNot(beNil())
            }
            
            it("can be announced") {
                expect(self.node.isAnnounced).toEventually(beFalsy())
                self.node.announce()
                expect(self.node.isAnnounced).toEventually(beTruthy())
                self.node.announce()
                expect(self.node.isAnnounced).toEventually(beTruthy())
            }
            
            it("has the coorinates") {
                expect(self.node.location.coordinate.latitude).to(equal(kNodeLatitude))
                expect(self.node.location.coordinate.longitude).to(equal(kNodeLongitude))
            }
            
            it("has a id") {
                expect(self.node.uid).to(equal(kNodeUid))
            }
            
            context("wasn't announced", {
                it("hasn't an announced date") {
                    expect(self.node.announcedDate).toEventually(beNil())
                }
            })
            
            context("was announced", {
                it("has an announced date") {
                    self.node.announce()
                    expect(self.node.announcedDate).toEventuallyNot(beNil())
                }
            })
            
            it("can have a name") {
                let name = "awesome name"
                self.node.name = name
                
                expect(self.node.name).to(equal(name))
            }
            
            it("can have the types") {
                let types = ["type" : "description"]
                self.node.types = types
                
                expect(self.node.types).to(equal(types))
            }
        }
    }
}