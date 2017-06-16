//
//  BookMountainEngine.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation
import Alamofire
import JavaScriptCore

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
        
        Alamofire.request(baseUrl!, method: .get, parameters: dicParam).response{ response in
            
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
                
                baseParam.paramArray = self.getBookList(strSource: utf8Text) as! NSMutableArray
                print(baseParam.paramArray)
                
            }
                baseParam.withresultobjectblock(0,"error",nil)
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
        book.author = BCTBookAnalyzer.dealDatailString(book.author)
        book.memo = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.memo)
        
        book.memo = BCTBookAnalyzer.dealDatailString(book.memo)
        
        return book
    }
    
    func getBookChapterList(baseParam:BMBaseParam)
    {
        let strUrl:String = baseParam.paramString
        
        Alamofire.request(strUrl).response{ response in
            
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
            
            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632)) {
                print("Data: \(contentText)")
                baseParam.paramArray = self.getChapterList(strSource: contentText,strUrl: baseParam.paramString) as! NSMutableArray
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }

        
    }
    
    func getChapterList(strSource:String,strUrl:String)->[BCTBookChapterModel]
    {
        var aryChapterList:[BCTBookChapterModel] = []

        do {
             let regular:NSRegularExpression =  try NSRegularExpression(pattern: (self.webSources?.parsingPatterns?.chapterItem)!, options: NSRegularExpression.Options.caseInsensitive)
            let results = regular.matches(in: strSource, range: NSMakeRange(0, strSource.characters.count))
            
            let strSourceNS = strSource as NSString
            for match in results
            {
                let bookchaptermodel = BCTBookChapterModel()
                
                //        bookchaptermodel.url = [strSource substringWithRange:[match rangeAtIndex:1]];
                //        bookchaptermodel.url = [NSString stringWithFormat:@"%@%@",strUrl,bookchaptermodel.url];
                //        bookchaptermodel.title = [strSource substringWithRange:[match rangeAtIndex:2]];
                //        bookchaptermodel.hostUrl = [self.sessionManager getBaseUrl];
                
//                bookchaptermodel.url = strSource.substring(with: match.rangeAt(<#Int#>))
                
//                let tempRange = match.rangeAt(1)
//                let indexRange = strSource.index(tempRange.index, offsetBy: tempRange.offsetBy)
                

                bookchaptermodel.url = strSourceNS.substring(with: match.rangeAt(1)) as String
                if(!bookchaptermodel.url.contains(self.webSources!.baseURL!))
                {
                    bookchaptermodel.url = String(format:"%@%@",arguments: [strUrl,bookchaptermodel.url])
                    
                }

//
//              bookchaptermodel.url = strSource.substring(with: indexRange)
                bookchaptermodel.title = strSourceNS.substring(with: match.rangeAt(2)) as String
                bookchaptermodel.hostUrl = self.webSources!.baseURL!
                
                aryChapterList.append(bookchaptermodel)
            }
            
        }catch {
            print(error)
        }
        
        
        return aryChapterList
    }
    
    
    func getBookChapterDetail(baseParam:BMBaseParam)
    {
        let strUrl:String = baseParam.paramString
        
        Alamofire.request(strUrl).response{ response in
            
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
            
            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632)) {
                print("Data: \(contentText)")
                baseParam.resultString = self.getChapterContent(strSource: contentText)
                let bookchaptermodel = baseParam.paramObject as! BCTBookChapterModel
                bookchaptermodel.content = self.getChapterContentText(strSource: baseParam.resultString)
                bookchaptermodel.htmlContent = baseParam.resultString
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }
    }
    
    func getChapterContent(strSource:String)->String {
        let strContent = BCTBookAnalyzer.getStrGroup1(strSource, pattern: self.webSources?.parsingPatterns?.chapterDetail)
        return strContent!
    }
    
    func getChapterContentText(strSource:String)->String
    {
        let strContentText = BCTBookAnalyzer.getChapterContentText(strSource)
        return strContentText!
    }
    
    func getCategoryBooksResult(baseParam:BMBaseParam)
    {
        
//                let str:String = String("http://zhannei.baidu.com/cse/search?q=校花&s=8253726671271885340&nsid=0&isNeedCheckDomain=1&jump=1")
//                let dic2 = str.urlParameters

        let strUrl:String = String(format: baseParam.paramString, baseParam.paramInt)
        
        Alamofire.request(strUrl).response{ response in
            
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
            
            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632)) {
                print("Data: \(contentText)")
//                baseParam.resultString = self.getChapterContent(strSource: contentText)
//                let bookchaptermodel = baseParam.paramObject as! BCTBookChapterModel
//                bookchaptermodel.content = self.getChapterContentText(strSource: baseParam.resultString)
//                bookchaptermodel.htmlContent = baseParam.resultString
                
//                baseParam.paramArray = self.getBookList(fromCategory strSource: utf8Text) as! NSMutableArray
                baseParam.paramArray = self.getBookList(fromCategory: contentText) as! NSMutableArray

                print(baseParam.paramArray)

                
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }
    }
    
    
    func getBookList(fromCategory strSource:String)->[BCTBookModel]
    {
        var bookList:[BCTBookModel] = []
        
        let arySource:[String] = BCTBookAnalyzer.getStrGroupAry(strSource, pattern: webSources?.parsingPatterns?.categoryList) as! [String]
        
        for subStrSource in arySource
        {
            let bookmode = getBookModel(fromCategory: subStrSource)
            bookList.append(bookmode)
        }
        
        return bookList
    }
    
    func getBookModel(fromCategory strSource:String)->BCTBookModel
    {
        let book:BCTBookModel = BCTBookModel()
        
        book.title = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.categoryListTitle)
//        book.imgSrc = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.imageSrc)
        book.bookLink = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.categoryListbookLink)
        
        book.author = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.categoryListAuthor)
        book.author = BCTBookAnalyzer.dealDatailString(book.author)
//        book.memo = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.memo)
//        
//        book.memo = BCTBookAnalyzer.dealDatailString(book.memo)
        
        if(webSources?.parsingPatterns?.categoryListImageFunction?.isEmpty == false)
        {
            let context: JSContext = JSContext()
//            let result1: JSValue = context.evaluateScript("1 + 3")
//            print(result1)  // 输出4
//            
//            // 定义js变量和函数
//            context.evaluateScript("var num1 = 10; var num2 = 20;")
            context.evaluateScript(webSources?.parsingPatterns?.categoryListImageFunction)
            
            let squareFunc = context.objectForKeyedSubscript("getImageUrl")
            book.imgSrc = (squareFunc?.call(withArguments: [book.bookLink]).toString())!
            
            print(book.imgSrc)
        }
        
        return book
    }
    
//    -(NSMutableArray*)getBookListFromCategoryH23w:(NSString*)strSource {
//    NSMutableArray *retAry = [NSMutableArray new];
//    
//    NSString *strPattern = @"<tr bgcolor=\"#FFFFFF\">[\\s\\S]*?</tr>";
//    NSArray *ary = [BCTBookAnalyzer getBookListBase:strSource pattern:strPattern];
//    for (NSTextCheckingResult *match in ary) {
//    NSString* substringForMatch = [strSource substringWithRange:match.range];
//    //        NSLog(@"Extracted URL: %@",substringForMatch);
//    
//    BCTBookModel *bookModel = [self getBookModelFromCategory:substringForMatch];
//    [retAry addObject:bookModel];
//    }
//    
//    return retAry;
//    }
//    
//    -(BCTBookModel*)getBookModelFromCategory:(NSString*)strSource {
//    BCTBookModel *bookmodel = [BCTBookModel new];
//    
//    bookmodel.bookLink = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<a href=\"([^\"]*)\" target=\"_blank\">"];
//    bookmodel.title = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<td class=\"L\">[\\s\\S]*?</a><a [^>]*>(.*?)</a>"];
//    bookmodel.author = [BCTBookAnalyzer getStrGroup1:strSource pattern:@"<td class=\"C\">(.*?)</td>[\\s\\S]*?<td class=\"R\">"];
//    
//    NSArray *aryBookNumber = [bookmodel.bookLink componentsSeparatedByString:@"/"];
//    
//    NSString *strBookNumber = [aryBookNumber objectAtIndex:[aryBookNumber count]-2];
//    
//    NSString *strBookNumberFront2 = [strBookNumber substringToIndex:2];
//    
//    //http://www.23wx.com/files/article/image/59/59945/59945s.jpg
//    bookmodel.imgSrc = [NSString stringWithFormat:@"http://www.23us.com/files/article/image/%@/%@/%@s.jpg",strBookNumberFront2,strBookNumber,strBookNumber];
//    
//    return bookmodel;
//    }

    
    
    
//    -(void)getCategoryBooksResult:(BMBaseParam*)baseParam {
//    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
//    
//    strUrl = [strUrl stringByReplacingOccurrencesOfString:[self.sessionManager getBaseUrl] withString:@""];
//    
//    [[H23wxSessionManager sharedClient] GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
//    
//    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
//    
//    NSMutableArray *bookList = nil;
//    
//    bookList = [self getBookListFromCategoryH23w:responseStr];
//    
//    baseParam.resultArray = bookList;
//    if (baseParam.withresultobjectblock) {
//    baseParam.withresultobjectblock(0,@"",nil);
//    }
//    
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//    NSLog(@"%@",[error userInfo]);
//    if (baseParam.withresultobjectblock) {
//    baseParam.withresultobjectblock(-1,@"",nil);
//    }
//    
//    }];
//    }

    

    
}
