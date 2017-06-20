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
    
    func getEncodedString(strSource:String,strEncoding:String)->String
    {
        var strRet:String = ""
        switch strEncoding {
        case "GB_18030_2000":
            strRet = (strSource as NSString).urlEncodedStringGB_18030_2000() as String
            break
            
        default:
            strRet = strSource
        }
        return strRet
    }
    
    func getSearchBookResult(baseParam:BMBaseParam)
    {
        var strKeyWord:String = baseParam.paramString
        
        //        if(baseParam.paramInt > 0)
        //        {
        //            baseParam.paramInt -= 1
        //        }
        
        strKeyWord = getEncodedString(strSource: strKeyWord, strEncoding: webSources!.requestEncoding!)
        
        let strPage:String = String(stringInterpolationSegment: baseParam.paramInt)
        let strUrl:String = String(format: (webSources?.searhURL)!, arguments: [strKeyWord,strPage])
        
        
        var dicParam = strUrl.urlParameters
        var baseUrl = strUrl.baseUrl
        if(webSources?.userParamDic == false)
        {
            dicParam = nil
            baseUrl = strUrl
        }
        
        
        
        
        
        Alamofire.request(baseUrl!, method: .get, parameters: dicParam).response{ response in
//            Alamofire.request(strUrl, method: .get, parameters: nil).response{ response in
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
            
            //            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8)
            if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: self.webSources!.parsingPatterns!.responseListEncoding!))
            {
                print("Data: \(contentText)")
                
                baseParam.paramArray = self.getBookList(strSource: contentText) as! NSMutableArray
                print(baseParam.paramArray)
                
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }
        
        
    }
    

    
    
    func getStringEncoding(strEncodingDescribe:String)->String.Encoding
    {
        var retEncoding:String.Encoding
        switch strEncodingDescribe {
        case "0x80000632":
            retEncoding = String.Encoding(rawValue: 0x80000632)
        case ".utf8":
            retEncoding = String.Encoding(rawValue: 0x80000632)
        default:
            retEncoding = .utf8
            break
        }
        return retEncoding
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
        if(webSources!.parsingPatterns!.bookLinkFunction! != "")
        {
            let context: JSContext = JSContext()
            context.evaluateScript(webSources?.parsingPatterns?.bookLinkFunction)
            
            let squareFunc = context.objectForKeyedSubscript("getBookLink")
            book.bookLink = (squareFunc?.call(withArguments: [book.bookLink]).toString())!
            
            print(book.bookLink)
        }
        
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
            
            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632))
            {
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
            context.evaluateScript(webSources?.parsingPatterns?.categoryListImageFunction)
            
            let squareFunc = context.objectForKeyedSubscript("getImageUrl")
            book.imgSrc = (squareFunc?.call(withArguments: [book.bookLink]).toString())!
            
            print(book.imgSrc)
        }
        
        return book
    }
    
    
    
    
    
    
    
    
    
    
}
