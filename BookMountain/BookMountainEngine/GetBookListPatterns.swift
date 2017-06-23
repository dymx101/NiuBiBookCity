//
//  GetBookListPatterns.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/21.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class GetBookListPatterns: BaseModel {

    var requestEncoding:String = ""
    var responseEncoding:String = ""
    var firstPageIsZero:Bool = false
    var userParamDic : Bool = false

    var booklist:String = ""
    
    
    var bookTitle:BookParsingItem? = nil
    var bookLink:BookParsingItem? = nil
    var author:BookParsingItem? = nil
    var imageSrc:BookParsingItem? = nil
    var memo:BookParsingItem? = nil
    

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if(key == "firstPageIsZero")
        {
            self.firstPageIsZero = (value as? Bool)!
        }
        else if(key == "userParamDic")
        {
            self.userParamDic = (value as? Bool)!
        }
    }
    
    override  func loadFromDic(key:String,dic:NSDictionary)
    {
        if(key == "bookTitle")
        {
            self.bookTitle = BookParsingItem(dict: dic)
        }
        else if(key == "bookLink")
        {
            self.bookLink = BookParsingItem(dict: dic)
        }
        else if(key == "author")
        {
            self.author = BookParsingItem(dict: dic)
        }
        else if(key == "imageSrc")
        {
            self.imageSrc = BookParsingItem(dict: dic)
        }
        else if(key == "memo")
        {
            self.memo = BookParsingItem(dict: dic)
        }
        
        
    }
    
}
