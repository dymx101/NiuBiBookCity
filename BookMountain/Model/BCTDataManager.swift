//
//  BCTDataManager.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/15.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BCTDataManager: NSObject {

    static let shared = BCTDataManager()
    var bookCategory:[BCTBookCategoryModel] = []
//    var dicBooksCategoryAry:[String:Any] = [:]
    
    var bookList : [BCTBookModel] = []
    var categoryBookList : [BCTBookModel] = []
    var historyKeyWord : String =  ""
    
    var pageIndex = 0
    var categoryPageIndex = 0
    
    func resetSearch(strKey:String) {
        if(strKey != historyKeyWord)
        {
            pageIndex = 0
            bookList = []
        }

    }
    func resetCategory(index:Int) {
        if(index == 0)
        {
            categoryPageIndex = 0
            categoryBookList = []
        }
        
    }
    
    override init() {
        super.init()
        self.loadData()
    }
    
    //  Converted with Swiftify v1.0.6355 - https://objectivec2swift.com/
    func loadData() {
        
        
        let bookCityConfig = BCTBookCityConfig.shared
        let count: Int = bookCityConfig.bookCategory.count
        for i in 0..<count {
            //        NSLog (@"Key: %@ for value: %@", key, value);
            let dicItem: [String: Any] = bookCityConfig.bookCategory[i] as! [String: Any]
            let bookcategorymodel = BCTBookCategoryModel()
            bookcategorymodel.curIndex = 1
            bookcategorymodel.name = dicItem[CATEGORYNAME] as! String
//            bookcategorymodel.strUrl = dicItem[URL] as! String 
            bookcategorymodel.categoryDescription = dicItem[DESCRIPTION] as! String
//            bookcategorymodel.bgColor = UIColorFromNSString(dicItem["bgColor"])
            bookcategorymodel.aryUrl = dicItem[URLARY] as! [String]
            bookCategory.append(bookcategorymodel)
        }
    }
    
    //  Converted with Swiftify v1.0.6355 - https://objectivec2swift.com/
//    func getBookArybyCategoryname(strCategoryname: String) -> [Any] {
//        var retArray: [Any] = dicBooksCategoryAry[strCategoryname]
//        if retArray == nil {
//            retArray = [Any]()
//            dicBooksCategoryAry[strCategoryname] = retArray
//        }
//        return retArray
//    }


    
    
}
