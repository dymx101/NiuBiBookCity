//
//  BookMountainTests.swift
//  BookMountainTests
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import XCTest
@testable import BookMountain

//static const CGFloat unitTestTimeout = 10;
//static const BOOL unitTestEnableLogging = false;

class BookMountainTests: XCTestCase {
    
    
    static var unitTestTimeout:CGFloat = 20
    static var unitTestEnableLogging:Bool = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    
        func testSearchKey()
        {
            let expect = self.expectation(description: "testSearchKey")
            let baseparam:BMBaseParam = BMBaseParam()
            baseparam.paramString = "校花"
            baseparam.paramInt = 1

                    baseparam.withresult = {(errorId)->Void in
            
                                    if(errorId == 0)
                                    {
                                        print("调用成功")
            
                                    }
                                    else
                                    {
            
                                    }
                    
//                    expect.fulfill()
                    }
            let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
            dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT)
            dicParam.setParam(baseparam)
            BMControl.sharedInstance().excute(dicParam)
            self.waitForExpectations(timeout: TimeInterval(BookMountainTests.unitTestTimeout)) { (error) in
                expect.fulfill()
                print(error ?? "")
            }
        }
    
//        func testBookChapterList()
//        {
//    
//            let expect = self.expectation(description: "testBookChapterList")
//            let baseparam:BMBaseParam = BMBaseParam()
//    
//    //http://www.23us.com/html/3/3764/
////            baseparam.paramString = "http://www.7788xs.org/read/48937.html"
//                        baseparam.paramString = "http://www.23us.com/html/3/3764/"
//            baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
//    
//                if(errorId == 0)
//                {
//                    print("调用成功")
//                    print(baseparam.paramArray)
//                }
//                else
//                {
//    
//                }
//                expect.fulfill()
//    
//            }
//            let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
//            dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST)
//            dicParam.setParam(baseparam)
//    
//            BMControl.sharedInstance().excute(dicParam)
//    
//            self.waitForExpectations(timeout: TimeInterval(BookMountainTests.unitTestTimeout)) { (error) in
//                            print(error ?? "")
//                        }
//    
//        }
    
    
//    func testBookDetail()
//    {
//        let expect = self.expectation(description: "testBookDetail")
//
//        let chapter:BCTBookChapterModel = BCTBookChapterModel()
////        chapter.url = "http://www.7788xs.org/read/48937/12066621.html"
//        
//        chapter.url = "http://www.23us.com/html/12/12100/9864883.html"
////        http://www.23us.com/html/3/3764/1276761.html
////        http://www.23us.com/html/12/12100/9864883.html
////        http://www.7788xs.org/read/48937/12066621.html
//        let baseparam:BMBaseParam = BMBaseParam()
//        baseparam.paramString = "http://www.23us.com/html/12/12100/9864883.html"
//        baseparam.paramObject = chapter
//        baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
//            if(errorId == 0){
//                print("调用成功")
//                print(baseparam.paramObject)
//            }
//            else{
//            }
//            expect.fulfill()
//            
//        }
//        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
//        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETBOOKCHAPTERDETAIL)
//        dicParam.setParam(baseparam)
//        BMControl.sharedInstance().excute(dicParam)
//        
//                    self.waitForExpectations(timeout: TimeInterval(BookMountainTests.unitTestTimeout)) { (error) in
//                                    print(error ?? "")
//                                }
//    }
    
    
//    func testBookCategory()
//    {
//        let expect = self.expectation(description: "testBookCategory")
//        let baseparam:BMBaseParam = BMBaseParam()
////        baseparam.paramString = "http://www.23us.com/html/12/12100/9864883.html"
//        baseparam.paramArray = BCTDataManager.shared.bookCategory[1].aryUrl as! NSMutableArray
//        baseparam.paramInt = 1
//
//        
//        baseparam.withresult = {(errorId)->Void in
//        
//                        if(errorId == 0)
//                        {
//                            print("调用成功")
//                            
//                        }
//                        else
//                        {
//                            
//                        }
//        
////        expect.fulfill()
//        }
//        
//        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
//        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETCATEGORYBOOKSRESULT)
//        dicParam.setParam(baseparam)
//        
//        BMControl.sharedInstance().excute(dicParam)
//        
//        
//        self.waitForExpectations(timeout: TimeInterval(BookMountainTests.unitTestTimeout)) { (error) in
//                                            print(error ?? "")
//                                        }
//        
//    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
}
