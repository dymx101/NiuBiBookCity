//
//  BookDownloadManager.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/23.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BookDownloadManager: NSObject {
    static let shared = BookDownloadManager()
    
    
    func download(bookmodel book:BCTBookModel)
    {
        if(book.aryChapterList.count>0)
        {
            downloadImp(bookmodel: book)
        }
        else
        {
            self.getChapters(bookmodel: book, finish: { () -> (Void) in
                self.downloadImp(bookmodel: book)
            })
        }
    }
    
    func downloadImp(bookmodel book:BCTBookModel)
    {
        let baseparam:BMBaseParam = BMBaseParam()
        
        baseparam.paramObject = book
        baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
            if(errorId == 0){
                print("调用成功")
            }
            else{
            }
            
        }
        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_DOWNLOADPLIST)
        dicParam.setParam(baseparam)
        BMControl.sharedInstance().excute(dicParam)
    }
    
    func getChapters(bookmodel book:BCTBookModel,finish:@escaping(()->(Void)))
    {
        
        let baseparam:BMBaseParam = BMBaseParam()
        
        //http://www.23us.com/html/3/3764/
        //            baseparam.paramString = "http://www.7788xs.org/read/48937.html"
        baseparam.paramString = book.bookLink
        baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
            
            if(errorId == 0)
            {
               book.aryChapterList = baseparam.paramArray as! [Any]
              finish()
            }
            else
            {
                
            }
            
        }
        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST)
        dicParam.setParam(baseparam)
        
        BMControl.sharedInstance().excute(dicParam)
    }

    
}
