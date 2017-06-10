//
//  BookAction.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/5/28.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BookAction: NSObject {
    
    public func getSearchBookResult(baseParam: BMBaseParam) {
        BookMountainEngineManager.shared.getSearchBookResult(baseParam: baseParam)
    }
    public func getBookChapterList(baseParam:BMBaseParam)
    {
        BookMountainEngineManager.shared.getBookChapterList(baseParam: baseParam)
    }
    public func getBookChapterDetail(baseParam:BMBaseParam)
    {
        BookMountainEngineManager.shared.getBookChapterDetail(baseParam: baseParam)
    }
    
    public func testIt()
    {
        print("12312312313123")
        print("12312312313123")
        print("12312312313123")
    }
    
    
    public func testIt(str:String)
    {
        print("12312312313123")
        print("12312312313123")
        print("12312312313123")
    }
}
