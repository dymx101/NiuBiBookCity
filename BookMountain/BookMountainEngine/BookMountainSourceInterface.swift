//
//  BookMountainSourceInterface.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

class BookMountainSource:NSObject {
    
    var baseURL: String?
    var requestEncoding: String.Encoding?
    var shouldPretendAsComputer: Bool?
    var parsingPatterns: BookParsingPatterns?
    
//    func searchURL(withKeyword keyword: String, page: Int) -> String {
//        return ""
//    }
    
    func loadConfig(dic:NSDictionary)
    {
        //        self.title = self.value(forKey: "1") as! String
        //        #keyPath(BookParsingPatterns.title)
        //        #keyPath(self.title)
        let structMirror = Mirror(reflecting: self).children
        let numChildren = structMirror.count
        print("child count:\(numChildren)")
        for case let (key,value) in structMirror {
            self.setValue("123", forKey: key!)
            //            print("name: \(key) value: \(value)")
        }
        
        
    }
}
