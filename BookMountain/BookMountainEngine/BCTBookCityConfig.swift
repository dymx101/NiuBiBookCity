//
//  BCTBookCityConfig.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/10.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BCTBookCityConfig: NSObject {
    static let shared = BCTBookCityConfig()
    
    var engineDics:[NSDictionary] = []
    var enginesDic:[NSDictionary] = []
    
    override init() {
        super.init()
        self.loadConfig()
    }
    
    func loadConfig()
    {
        if let plistPath = Bundle.main.path(forResource: "BookMountainConfiguration", ofType: "plist") {
            let dicConfig = NSDictionary(contentsOfFile: plistPath)
            print(loadConfig ?? "get config error")
            
            engineDics = dicConfig?["sources"] as! [NSDictionary];
//            for engineDic in engineDics
//            {
//                let engine = BookMountainEngine(dict: engineDic)
//                
//            }
        }
        
        
        if let plistPath = Bundle.main.path(forResource: "bookCityConfig", ofType: "plist") {
            let dicConfig = NSDictionary(contentsOfFile: plistPath)
            
            
        }
        
    }
    
}
