//
//  BookMountainEngineManager.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/5/28.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BookMountainEngineManager: NSObject {
    static let shared = BookMountainEngineManager()
    
    var engineList:[BookMountainEngine]=[]
    
    public func getSearchBookResult(baseParam: BMBaseParam) {
        
        
        
    }
    
    //
    func loadConfig()
    {
        if let plistPath = Bundle.main.path(forResource: "BookMountainConfiguration", ofType: "plist") {
            let dicConfig = NSDictionary(contentsOfFile: plistPath)
            print(loadConfig ?? "get config error")
        }
        
        
    }

}
