//
//  TypeTranslator.swift
//  Talking Companion
//
//  Created by Sergey Butenko on 10/24/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

import UIKit

let kEnglishLocale = "en"
let kRussianLocale = "ru"
let kDefaultLanguage = kEnglishLocale

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

class TypeTranslator {
    
    private let language:String
    public let json:JSON
    private let relevantTypes:[String]
    
    init (var language:String) {
        language = language.lowercaseString
        if (language == kEnglishLocale || language == kRussianLocale) {
            self.language = language
        }
        else {
            self.language = kDefaultLanguage
        }
        
        let jsonPath = NSBundle.mainBundle().pathForResource("translation", ofType: "json")!
        let jsonData = NSData(contentsOfFile: jsonPath)
        self.json = JSON(jsonData as NSData!)
        self.relevantTypes = ["amenity", "shop", "leisure", "historic", "tourism", "bridge", "highway", "public_transport", "railway", "building", "place", "landuse", "natural", "man_made"]
    }
    
    func translatedTypeForTypes(#types:[String:String]) -> String? {
        for mayType in relevantTypes {
            if let valueForType = types[mayType] {
                return self.json[mayType][valueForType]["translation"][self.language].string
            }
        }
        
        return nil
    }
    
    func traslatedNameForSpeaking(#node:OSMNode) -> String {
        if language == kRussianLocale {
            if let name = node.types["name:\(language)"] {
                return name
            }
            return node.name
        }
        else {
            if !isCyrillicName(node.name) {
                return node.name
            }
            if let name = node.types["name:\(language)"] {
                return name
            }
            return romanizationOfRussianString(node.name)
        }
    }
    
    func traslatedNameForDisplaying(#node:OSMNode) -> String {
        if let name = node.types["name:\(language)"] {
            return name
        }
        return node.name
    }
    
    private func isCyrillicName(name:String) -> Bool {
        for char in name {
            if (char > "а" && char < "я") || (char > "А" && char < "Я") {
                return true
            }
        }
        
        return false
    }
    
    private func romanizationOfRussianString(var string:String) -> String {
        string = string.lowercaseString
        var romanization = ""
        
        for var i = 0; i < count(string); i++ {
            let char = Array(string)[i]
            
            switch char {
                case "а": romanization += "a"
                case "б": romanization += "b"
                case "в": romanization += "v"
                case "г": romanization += "g"
                case "д": romanization += "d"
                case "е": if i == 0 || (i > 0 && (string[i-1] == "й" || string[i-1] == "ь" || string[i-1] == "ъ" || isVowelChar(string[i-1]) )) {
                    romanization += "ye"
                }
                else {
                    romanization += "e"
                }
                case "ё": if i == 0 || (i > 0 && (string[i-1] == "й" || string[i-1] == "ь" || string[i-1] == "ъ" || isVowelChar(string[i-1]) )) {
                    romanization += "yë"
                }
                else {
                    romanization += "ë"
                }
                case "ж": romanization += "zh"
                case "з": romanization += "z"
                case "и": romanization += "i"
                case "й": if i < count(string)-1 && (string[i+1] == "а" || string[i+1] == "у" || string[i+1] == "ы" || string[i+1] == "э") {
                    romanization += "y·"
                }
                else {
                    romanization += "y"
                }
                case "к": romanization += "k"
                case "л": romanization += "l"
                case "м": romanization += "m"
                case "н": romanization += "n"
                case "о": romanization += "o"
                case "п": romanization += "p"
                case "р": romanization += "r"
                case "с": romanization += "s"
                case "т": romanization += "t"
                case "у": romanization += "u"
                case "ф": romanization += "f"
                case "х": romanization += "kh"
                case "ц": romanization += "ts"
                case "ч": romanization += "ch"
                case "ш": romanization += "sh"
                case "щ": romanization += "shch"
                case "ъ": romanization += "\""
                case "ы": if i < count(string)-1 && (string[i+1] == "а" || string[i+1] == "у" || string[i+1] == "ы" || string[i+1] == "э") {
                    romanization += "y·"
                }
                else if i > 0 && isVowelChar(string[i-1]) {
                    romanization += "·y"
                }
                else {
                    romanization += "y"
                }
                case "ь": romanization += "'"
                case "э": if i > 0 && string[i-1] != "й" && isConsonantChar(string[i-1]){
                    romanization += "·e"
                }
                else {
                    romanization += "e"
                }
                case "ю": romanization += "yu"
                case "я": romanization += "ya"
                default: romanization += "\(char)"
            }
        }
        return romanization
    }
    
    private func isVowelChar(char:String) -> Bool {
        switch char {
            case "а", "е", "ё", "и", "о", "у", "ы", "э", "ю", "я": return true
            default: return false
        }
    }
    private func isConsonantChar(char:String) -> Bool {
        return !isVowelChar(char)
    }
}
