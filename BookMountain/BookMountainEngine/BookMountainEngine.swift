//
//  BookMountainEngine.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation
import Alamofire

class BookMountainEngine:NSObject {
    
    var webSources: BookMountainSource? = nil

    func search(withKeyword keyword:String, page: Int) {
        
    }
    override init() {
        
    }
    init(dict:NSDictionary) {
        super.init()
        self.loadConfig(dict: dict)
    }
    
    
    func loadConfig(dict:NSDictionary) {
        webSources = BookMountainSource(dict: dict)
    }
    
    func getSearchBookResult(baseParam:BMBaseParam)
    {
        let strKeyWord:String = baseParam.paramString
        if(baseParam.paramInt > 0)
        {
            baseParam.paramInt -= 1
        }
        
        let strPage:String = String(stringInterpolationSegment: baseParam.paramInt)
        let strUrl:String = String(format: (webSources?.searhURL)!, arguments: [strKeyWord,strPage])
        
//        let curUrl = URL(string: strUrl);
//        
//        
//        let dict = ["q":strKeyWord,"p":strPage,"s":"8253726671271885340","nsid":"0"]
        
//        let str:String = String("http://zhannei.baidu.com/cse/search?q=校花&s=8253726671271885340&nsid=0&isNeedCheckDomain=1&jump=1")
//        let dic2 = str.urlParameters
        
        //let strUrl2 = "http://www.baidu.com"
        let dicParam = strUrl.urlParameters
        let baseUrl = strUrl.baseUrl
        
        Alamofire.request(baseUrl!, method: .get, parameters: dicParam).response
//        Alamofire.request(webSources?.searhURL ,parameters: dict)
            { response in
            
//            print("Request: \(response.request)")
//            print("Response: \(response.response)")
//            print("Error: \(response.error)")
            if(response.error != nil)
            {
                if let error = (response.error as NSError?)
                {
                    baseParam.withresultobjectblock(Int32(error.code),error.localizedDescription,nil)
                }
                else
                {
                    baseParam.withresultobjectblock(-1,"error",nil)
                }
                return
            }
                
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                
                let booklist = self.getBookList(strSource: utf8Text)
                
                print(booklist)
                
                baseParam.withresultobjectblock(200,"error",nil)
                
            }
//            print(response)
        }
      

    }
    
    func getBookList(strSource:String)->[BCTBookModel]
    {
        var bookList:[BCTBookModel] = []
        
        let arySource:[String] = BCTBookAnalyzer.getStrGroupAry(strSource, pattern: webSources?.parsingPatterns?.list) as! [String]
        
        for subStrSource in arySource
        {
            let bookmode = getBookModel(strSource: subStrSource)
            bookList.append(bookmode)
        }
        
        return bookList
    }
    
    func getBookModel(strSource:String)->BCTBookModel
    {
        let book:BCTBookModel = BCTBookModel()
        
        book.title = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.title)
        book.imgSrc = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.imageSrc)
        book.bookLink = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.bookLink)
        
        book.author = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.author)
        book.memo = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.memo)
        
        
        
//        book.imgSrc = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<img src=\"([^\"]*)\""];
//        book.bookLink = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a cpos=\"img\" href=\"([^\"]*)\""];
//        
//        book.author = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a cpos=\"author\"[^>]*>([^<]*)</a>"];
//        book.author = [book.author stringByReplacingOccurrencesOfString:@" " withString:@""];
//        book.author = [book.author stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//        
//        
//        book.memo = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<p class=\"result-game-item-desc\">[^.]*..([\\s\\S]*?)</p>"];
//        book.memo = [book.memo stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
//        book.memo = [book.memo stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
        
        
        
        return book
    }
    
//    -(NSArray*)getBookListH23wx:(NSString*)strSource
//    {
//    NSString *strPattern = @"<div class=\"result-item result-game-item\">[\\s\\S]*?</p>\\s*?</div>";
//    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
//    NSMutableArray *bookList = [[NSMutableArray alloc]init];
//    
//    for (NSString* subStrSource in arySource) {
//    BCTBookModel *book = [self getBookModeH23wx:subStrSource];
//    [bookList addObject:book];
//    }
//    
//    return bookList;
//    }
//    
//    -(BCTBookModel*)getBookModeH23wx:(NSString*)strSource {
//    BCTBookModel *book = [BCTBookModel new];
//    
//    book.title = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a cpos=\"title\" href=\"\[^\"]*\" title=\"([^\"]*)\""];
//    book.imgSrc = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<img src=\"([^\"]*)\""];
//    book.bookLink = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a cpos=\"img\" href=\"([^\"]*)\""];
//    
//    book.author = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a cpos=\"author\"[^>]*>([^<]*)</a>"];
//    book.author = [book.author stringByReplacingOccurrencesOfString:@" " withString:@""];
//    book.author = [book.author stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//    
//    
//    book.memo = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<p class=\"result-game-item-desc\">[^.]*..([\\s\\S]*?)</p>"];
//    book.memo = [book.memo stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
//    book.memo = [book.memo stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
//    
//    return book;
//    }
    
}
