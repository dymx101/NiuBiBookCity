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
        
        
        for engine in engineList
        {
            engine.getSearchBookResult(baseParam: baseParam)
            break
        }
        
    }
    
    public func getBookChapterList(baseParam: BMBaseParam) {
        
        for engine in engineList
        {
            if(baseParam.paramString.contains((engine.webSources?.baseURL)!))
            {
                engine.getBookChapterList(baseParam: baseParam)
                 break
            }
            
        }
        
    }
    
    public func getBookChapterDetail(baseParam:BMBaseParam)
    {
        for engine in engineList
        {
            if(baseParam.paramString.contains((engine.webSources?.baseURL)!))
            {
                engine.getBookChapterDetail(baseParam: baseParam)
            }
            
        }
    }
    
    public func getCategoryBooksResult(baseParam:BMBaseParam)
    {
        for engine in engineList
        {
            for strUrl in baseParam.paramArray
            {
                if((strUrl as! String).contains((engine.webSources?.baseURL)!))
                {
                    baseParam.paramString = strUrl as! String
                    engine.getCategoryBooksResult(baseParam: baseParam)
                }

            }
        }
        baseParam.withresultobjectblock = {(errorId,message,id)->Void in
            
            if(errorId == 0)
            {
                print("调用成功")
                print(baseParam.paramObject)
            }
            else
            {
                
            }
            baseParam.withresult(errorId)
            
        }

    }
    
    
    override init() {
        super.init()
        self.loadEngines()
        
    }
    
    func loadEngines()
    {
        for engineDic in BCTBookCityConfig.shared.engineDics
        {
            let engine = BookMountainEngine(dict: engineDic)
            engineList.append(engine)
        }
    }
    

    


}
