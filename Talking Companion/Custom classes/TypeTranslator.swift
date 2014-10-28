//
//  TypeTranslator.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 10/24/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

let kDefaultLanguage = "en"

private let _lang = NSLocale.preferredLanguages().first as String
private let _SingletonSharedInstance = TypeTranslator(language:_lang)

class TypeTranslator {
    
    private let lang:String
    private let json:JSONValue
    
    class var sharedInstance : TypeTranslator {
        return _SingletonSharedInstance
    }
    
    init (language:String) {
        if (language == "en" || language == "ru") {
            self.lang = language
        }
        else {
            self.lang = kDefaultLanguage
        }
        
        let jsonPath = NSBundle.mainBundle().pathForResource("translation", ofType: "json")!
        let jsonData = NSData(contentsOfFile: jsonPath)
        self.json = JSONValue(jsonData as NSData!)
    }

    func translateAmenity(amenity:String) -> String {
        if let type = self.json["amenity"][amenity]["translation"][self.lang].string {
            return type
        }
        return ""
    }
}
