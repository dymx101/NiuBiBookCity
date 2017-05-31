//
//  BaseModel.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/5/30.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    
    override init() {
        // 在构造函数中,如果没有明确super.init(),那么系统会帮助调用super.init()
         super.init()
    }
    
    init(dict:NSDictionary) {
        super.init()
        self.loadFrom(dic: dict)
    }
    
    func loadFrom(dic:NSDictionary)
    {
        let structMirror = Mirror(reflecting: self).children
        let numChildren = structMirror.count
        print("child count:\(numChildren)")
        for case let (k, _) in structMirror {
            
            if(dic[k!] is NSDictionary)
            {
                self.loadFromDic(key:k!, dic: dic[k!] as! NSDictionary)
            }
            else
            {
                self.setValue(dic[k!], forKey: k!)
            }
        }
    }
    
    func loadFromDic(key:String,dic:NSDictionary)
    {
        
    }
    
}
