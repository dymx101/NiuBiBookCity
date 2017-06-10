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
//        let regular:NSRegularExpression = NSRegularExpression(pattern: (self.webSources?.parsingPatterns?.chapterItem)!, options: NSRegularExpression.Options.caseInsensitive)
        
//               let regular:NSRegularExpression = NSRegularExpression(pattern: <#T##String#>, options: <#T##NSRegularExpression.Options#>)
//        let regular:NSRegularExpression = NSRegularExpression(pattern: <#T##String#>, options: <#T##NSRegularExpression.Options#>)
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
//                bookchaptermodel.url = strSource.substring(with: indexRange)
                bookchaptermodel.title = strSourceNS.substring(with: match.rangeAt(2)) as String
                bookchaptermodel.hostUrl = self.webSources!.baseURL!
                
                aryChapterList.append(bookchaptermodel)
            }
            
        }catch {
            print(error)
        }
        
        
        return aryChapterList
    }
    
    
//    -(void)getBookChapterDetail:(BMBaseParam*)baseParam {
//    //paramString2 保存chapterDetail url
//    NSString *strUrl = baseParam.paramString2;
//    
//    strUrl = [strUrl stringByReplacingOccurrencesOfString:[self.sessionManager getBaseUrl] withString:@""];
//    
//    __weak H23wxEngine *weakSelf = self;
//    [[H23wxSessionManager sharedClient] GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
//    
//    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
//    
//    baseParam.resultString = [weakSelf getChapterContent:responseStr];
//    
//    BCTBookChapterModel* bookchaptermodel = (BCTBookChapterModel*)baseParam.paramObject;
//    bookchaptermodel.content = [weakSelf getChapterContentText:baseParam.resultString];
//    bookchaptermodel.htmlContent = baseParam.resultString;
//    if (baseParam.withresultobjectblock) {
//    baseParam.withresultobjectblock(0,@"",nil);
//    }
//    
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error)
//    {
//    NSLog(@"%@",[error userInfo]);
//    if (baseParam.withresultobjectblock) {
//    baseParam.withresultobjectblock(-1,@"",nil);
//    }
//    
//    }];
//    }
    
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
//                baseParam.paramArray = self.getChapterList(strSource: contentText,strUrl: baseParam.paramString) as! NSMutableArray
                
                //    baseParam.resultString = [weakSelf getChapterContent:responseStr];
                //
                //    BCTBookChapterModel* bookchaptermodel = (BCTBookChapterModel*)baseParam.paramObject;
                //    bookchaptermodel.content = [weakSelf getChapterContentText:baseParam.resultString];
                //    bookchaptermodel.htmlContent = baseParam.resultString;
                
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
//    -(NSString*)getChapterContent:(NSString*)strSource {
//    NSString *strPattern = @"<dd id=\"contents\">([\\s\\S]*?)</dd>";
//    NSString *strContent = [BCTBookAnalyzer getStrGroup1:strSource pattern:strPattern];
//    
//    return strContent ? : @"";
//    }
    
//    -(NSString*)getChapterContentText:(NSString*)strSource {
//    NSString *strContent = [BCTBookAnalyzer getChapterContentText:strSource];
//    return strContent ? : @"";
//    }

    

    
}
