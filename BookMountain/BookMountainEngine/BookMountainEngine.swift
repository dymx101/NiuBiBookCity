//
//  BookMountainEngine.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation
import Alamofire

//protocol BookMountainEngineInterface {
//    func search(withKeyword keyword:String, page: Int)
//}

class BookMountainEngine:NSObject {
    
    var webSources: BookMountainSource? = nil
//    var bookPatterns:BookParsingPatterns? = nil
    
    
    
    func search(withKeyword keyword:String, page: Int) {
        
    }
    override init() {
        // 在构造函数中,如果没有明确super.init(),那么系统会帮助调用super.init()
        
    }
    init(dict:NSDictionary) {
        super.init()
        self.loadConfig(dict: dict)
    }
    
    
    func loadConfig(dict:NSDictionary) {
        webSources = BookMountainSource(dict: dict)
    }
    
//    -(void)getSearchBookResult:(BMBaseParam*)baseParam
//    {
//    
//    }
    
    func getSearchBookResult(baseParam:BMBaseParam)
    {
//        NSString *strKeyWord = baseParam.paramString;
//        
//        if(baseParam.paramInt > 0) {
//            baseParam.paramInt--;
//        }
//        NSString *stringPage = [NSString stringWithFormat:@"%ld",(long)baseParam.paramInt];
//        
//        //    NSDictionary *dict = @{@"q":strKeyWord,@"p":stringPage,@"s":@"15772447660171623812",@"nsid":@"",@"entry":@"1"};
//        //    NSString *strUrl = @"/cse/search";
//        NSDictionary *dict = @{@"q":strKeyWord,@"p":stringPage,@"s":@"8253726671271885340",@"nsid":@""};
//        NSString *strUrl = @"/cse/search";
        
        
        let strKeyWord:String = baseParam.paramString
        if(baseParam.paramInt > 0)
        {
            baseParam.paramInt -= 1
        }
        
        let strPage:String = String(stringInterpolationSegment: baseParam.paramInt)
        let strUrl:String = String(format: (webSources?.searhURL)!, arguments: [strKeyWord,strPage])
        
        
        let strUrl2 = "http://www.baidu.com"
        Alamofire.request(strUrl2).response { response in
            
            print("Request: \(response.request)")
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
//            print(response)
        }
         //       let strUrl:String = String(format: <#T##String#>, arguments: <#T##[CVarArg]#>)
        
//
//        
//        [[So23wxSessionManager sharedClient] GET:strUrl parameters:dict success:^(NSURLSessionDataTask * __unused task, id responseObject) {
//            
//            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            
//            NSMutableArray *bookList = nil;
//            
//            bookList = [[NSMutableArray alloc]initWithArray:[self getBookListH23wx:responseStr]];
//            
//            baseParam.resultArray = bookList;
//            if (baseParam.withresultobjectblock) {
//            baseParam.withresultobjectblock(0,@"",nil);
//            }
//            
//            } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//            NSLog(@"%@",[error userInfo]);
//            
//            if (baseParam.withresultobjectblock) {
//            baseParam.withresultobjectblock(-1,@"",nil);
//            }
//            }];
    }
}
