//
//  BookMountainSourceInterface.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

class BookMountainSource:BaseModel {
    
//    static public var feilds:[String] = []
//    
//    static public let dictA = ["baseURL":"baseURL","shouldPretendAsComputer":false] as [String : Any]
    
    var baseURL: String?
    var requestEncoding: String?
    var searhURL: String?
    var shouldPretendAsComputer: Bool?
    var parsingPatterns: BookParsingPatterns?
    

    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if(key == "shouldPretendAsComputer")
        {
            self.shouldPretendAsComputer = value as? Bool
        }

    }
    
    override  func loadFromDic(key:String,dic:NSDictionary)
    {
        if(key == "parsingPatterns")
        {
            parsingPatterns = BookParsingPatterns(dict: dic)
        }
    }
}
