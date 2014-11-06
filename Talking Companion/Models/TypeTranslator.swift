//
//  TypeTranslator.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 10/24/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

let kDefaultLanguage = "en"

class TypeTranslator {
    
    private let language:String
    private let json:JSONValue
    private let relevantTypes:[String]
    
    init (language:String) {
        if (language == "en" || language == "ru") {
            self.language = language
        }
        else {
            self.language = kDefaultLanguage
        }
        
        let jsonPath = NSBundle.mainBundle().pathForResource("translation", ofType: "json")!
        let jsonData = NSData(contentsOfFile: jsonPath)
        self.json = JSONValue(jsonData as NSData!)
        self.relevantTypes = ["amenity", "place", "building", "shop", "natural", "bridge", "landuse", "tourism", "railway", "public_transport", "leisure"]
    }
    
    func translatedTypeForTypes(#types:[String:String]) -> String? {
        for mayType in relevantTypes {
            if let valueForType = types[mayType] {
                return self.json[mayType][valueForType]["translation"][self.language].string
            }
        }
        
        return nil
    }
}
