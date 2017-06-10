//
//  ViewController.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let str:String = String("http://zhannei.baidu.com/cse/search?q=校花&s=8253726671271885340&nsid=0&isNeedCheckDomain=1&jump=1")
//        let dic = str.urlParameters
//        print(dic)
////        BookMountainEngineManager.shared;
//        test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func test()
    {
//        BMBaseParam* baseparam = [BMBaseParam new];
//        
//        //参数
//        baseparam.paramString = keyword;
//        baseparam.paramInt = pageIndex;
//        
//        __weak BMBaseParam *weakBaseParam = baseparam;
//        baseparam.withresultobjectblock = ^(int intError,NSString* strMsg,id obj) {
//            
//            [weakBaseParam reducePendingCallbacks];
//            
//            if (intError == 0) {
//                
//                NSArray *books = weakBaseParam.resultArray;
//                
//                if (books.count > 0) {
//                    NSArray *sortedBooks = [books sortedArrayUsingComparator:^NSComparisonResult(BCTBookModel * _Nonnull obj1, BCTBookModel * _Nonnull obj2) {
//                        
//                        NSInteger quality1 = [obj1 quality];
//                        NSInteger quality2 = [obj2 quality];
//                        
//                        if (quality1 > quality2) {
//                        return NSOrderedAscending;
//                        } else if (quality1 < quality2) {
//                        return NSOrderedDescending;
//                        }
//                        
//                        return NSOrderedSame;
//                        }];
//                    
//                    NSArray *updatedBooks = [self.books arrayByAddingObjectsFromArray:sortedBooks];
//                    
//                    self.books = [updatedBooks mutableCopy];
//                    [subscriber sendNext:RACTuplePack(books, nil)];
//                    
//                } else {
//                    
//                    self.books = [self.books mutableCopy];
//                    [subscriber sendNext:RACTuplePack(books, nil)];
//                }
//                
//            } else {
//                //                [subscriber sendError:[NSError errorWithDomain:@"获取数据失败" code:kBCTErrorSearchBook userInfo:nil]];
//            }
//            
//            if (![weakBaseParam hasMoreCallBacks]) {
//                [subscriber sendCompleted];
//            }
//        };
//        
//        NSMutableDictionary* dicParam = [NSMutableDictionary createParamDic];
//        [dicParam setActionID:DEF_ACTIONID_BOOKACTION strcmd:DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT];
//        [dicParam setParam:baseparam];
//        
//        [SharedControl excute:dicParam];
        
        
        
        //        BMBaseParam* baseparam = [BMBaseParam new];
        //
        //        //参数
        //        baseparam.paramString = keyword;
        //        baseparam.paramInt = pageIndex;
        
        
        let baseparam:BMBaseParam = BMBaseParam()
        baseparam.paramString = "校花"
        baseparam.paramInt = 1
        baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
            print("13241234123412")
            print("13241234123412")
            print("13241234123412")
        }
        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT)
//                dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: "testIt:")
        dicParam.setParam(baseparam)
        
        
        BMControl.sharedInstance().excute(dicParam)
        
    }

}

