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
    
    
    static var unitTestTimeout:CGFloat = 10
    static var unitTestEnableLogging:Bool = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    
//        func testSearchKey()
//        {
//            let expect = self.expectation(description: "testSearchKey")
//            let baseparam:BMBaseParam = BMBaseParam()
//            baseparam.paramString = "校花"
//            baseparam.paramInt = 1
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
//            dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT)
//            dicParam.setParam(baseparam)
//            BMControl.sharedInstance().excute(dicParam)
//            self.waitForExpectations(timeout: TimeInterval(BookMountainTests.unitTestTimeout)) { (error) in
//                print(error ?? "")
//            }
//        }
    
        func testBookChapterList()
        {
    
            let expect = self.expectation(description: "testBookList")
            let baseparam:BMBaseParam = BMBaseParam()
            baseparam.paramString = "http://www.7788xs.org/read/48937.html"
            baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
    
                if(errorId == 0)
                {
                    print("调用成功")
                    print(baseparam.paramArray)
                }
                else
                {
    
                }
                expect.fulfill()
    
            }
            let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
            dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST)
            dicParam.setParam(baseparam)
    
            BMControl.sharedInstance().excute(dicParam)
    

    
        }
    
    
//    func testBookDetail()
//    {
//        let chapter:BCTBookChapterModel = BCTBookChapterModel()
//        chapter.url = "http://www.23us.com/html/12/12100/9864883.html"
//        
//        let expect = self.expectation(description: "testBookDetail")
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
//    }
    
    
//    func testBookCategory()
//    {
//        let baseparam:BMBaseParam = BMBaseParam()
////        baseparam.paramString = "http://www.23us.com/html/12/12100/9864883.html"
//        baseparam.paramArray = BCTDataManager.shared.bookCategory[0].aryUrl as! NSMutableArray
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
//        
//        }
//        
//        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
//        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETCATEGORYBOOKSRESULT)
//        dicParam.setParam(baseparam)
//        
//        BMControl.sharedInstance().excute(dicParam)
//        
//    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
