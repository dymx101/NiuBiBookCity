//
//  BookParsingPatterns.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

/// BookParsingPatterns 用于配置图书解析时的正则表达式
class BookParsingPatterns:BaseModel {
    
    var getSearchBookResult:GetBookListPatterns? = nil
    var getBookChapterList:BookParsingItem? = nil
    var getBookChapterDetail:BookParsingItem? = nil
    var getCategoryBooksResult:GetBookListPatterns? = nil


    override  func loadFromDic(key:String,dic:NSDictionary)
    {
        if(key == "getSearchBookResult")
        {
            self.getSearchBookResult = GetBookListPatterns(dict: dic)
        }
        else if(key == "getBookChapterList")
        {
            self.getBookChapterList = BookParsingItem(dict: dic)
        }
        else if(key == "getBookChapterDetail")
        {
            self.getBookChapterDetail = BookParsingItem(dict: dic)
        }
        else if(key == "getCategoryBooksResult")
        {
            self.getCategoryBooksResult = GetBookListPatterns(dict: dic)
        }
        
    }
    
    
}
