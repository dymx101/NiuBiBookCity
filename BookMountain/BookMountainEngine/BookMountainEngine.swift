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
    
    
    
    // MARK:- getSearchBookResult
    func getSearchBookResult(baseParam:BMBaseParam)
    {
        var strKeyWord:String = baseParam.paramString
        if (webSources?.parsingPatterns?.getSearchBookResult?.firstPageIsZero)!
        {
            if(baseParam.paramInt > 0)
            {
                baseParam.paramInt -= 1
            }
        }
        
        
        strKeyWord = getEncodedString(strSource: strKeyWord, strEncoding: (self.webSources?.parsingPatterns?.getSearchBookResult?.requestEncoding)!)
        
        let strPage:String = String(stringInterpolationSegment: baseParam.paramInt)
        let strUrl:String = String(format: (webSources?.searhURL)!, arguments: [strKeyWord,strPage])
        
        
        var dicParam = strUrl.urlParameters
        var baseUrl = strUrl.baseUrl
        if(webSources?.parsingPatterns?.getSearchBookResult?.userParamDic == false)
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
            
            //  if let data = response.data, let utf8Text = String(data: data, encoding: .utf8)
            if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: (self.webSources!.parsingPatterns!.getSearchBookResult?.responseEncoding)!))
            {
                print("Data: \(contentText)")
                
                baseParam.paramArray = self.getBookList(strSource: contentText) as! NSMutableArray
                print(baseParam.paramArray)
                
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }
        
        
    }
    
    
    func getBookList(strSource:String)->[BCTBookModel]
    {
        var bookList:[BCTBookModel] = []
        
        let arySource:[String] = BCTBookAnalyzer.getStrGroupAry(strSource, pattern: webSources?.parsingPatterns?.getSearchBookResult!.booklist) as! [String]
        
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
        
//        book.title = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.title)
        
        self.webSources?.parsingPatterns?.getSearchBookResult?.bookTitle?.inputParam = strSource
        book.title = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getSearchBookResult?.bookTitle)!)
        
        self.webSources?.parsingPatterns?.getSearchBookResult?.imageSrc?.inputParam = strSource
        book.imgSrc = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getSearchBookResult?.imageSrc)!)
        
        self.webSources?.parsingPatterns?.getSearchBookResult?.bookLink?.inputParam = strSource
        book.bookLink = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getSearchBookResult?.bookLink)!)
        
        self.webSources?.parsingPatterns?.getSearchBookResult?.author?.inputParam = strSource
        book.author = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getSearchBookResult?.author)!)
        book.author = BCTBookAnalyzer.dealDatailString(book.author)
        
        
        self.webSources?.parsingPatterns?.getSearchBookResult?.memo?.inputParam = strSource
        book.memo = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getSearchBookResult?.memo)!)
        book.memo = BCTBookAnalyzer.dealDatailString(book.memo)
        
        return book
    }
    // MARK:- getBookChapterList
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
            
            //            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632))
            if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: (self.webSources!.parsingPatterns!.getBookChapterList?.responseEncoding)!))
            {
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
            let regular:NSRegularExpression =  try NSRegularExpression(pattern: (self.webSources?.parsingPatterns?.getBookChapterList!.parsing)!, options: NSRegularExpression.Options.caseInsensitive)
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
                
                bookchaptermodel.title = strSourceNS.substring(with: match.rangeAt(2)) as String
                bookchaptermodel.hostUrl = self.webSources!.baseURL!
                
                aryChapterList.append(bookchaptermodel)
            }
            
        }catch {
            print(error)
        }
        
        
        return aryChapterList
    }
    
    // MARK:- getBookChapterDetail
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
            
            //            if let data = response.data, let contentText = String(data: data, encoding: String.Encoding(rawValue: 0x80000632))
            if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: (self.webSources!.parsingPatterns!.getBookChapterDetail?.responseEncoding)!))
            {
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
        let strContent = BCTBookAnalyzer.getStrGroup1(strSource, pattern: self.webSources?.parsingPatterns?.getBookChapterDetail?.parsing)
        return strContent!
    }
    
    func getChapterContentText(strSource:String)->String
    {
        let strContentText = BCTBookAnalyzer.getChapterContentText(strSource)
        return strContentText!
    }
    
    // MARK:- getCategoryBooksResult
    func getCategoryBooksResult(baseParam:BMBaseParam)
    {
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
            if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: (self.webSources!.parsingPatterns!.getCategoryBooksResult?.responseEncoding)!))
            {
                print("Data: \(contentText)")
                
                baseParam.paramArray = self.getBookList(fromCategory: contentText) as! NSMutableArray
                
                print(baseParam.paramArray)
                
                
            }
            baseParam.withresultobjectblock(0,"error",nil)
        }
    }
    
    
    func getBookList(fromCategory strSource:String)->[BCTBookModel]
    {
        var bookList:[BCTBookModel] = []
        
        let arySource:[String] = BCTBookAnalyzer.getStrGroupAry(strSource, pattern: webSources?.parsingPatterns?.getCategoryBooksResult!.booklist) as! [String]
        
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
        
        //        book.title = BCTBookAnalyzer.getStrGroup1(strSource, pattern: webSources?.parsingPatterns?.title)
        
        self.webSources?.parsingPatterns?.getCategoryBooksResult?.bookTitle?.inputParam = strSource
        book.title = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.bookTitle)!)

        self.webSources?.parsingPatterns?.getCategoryBooksResult?.bookLink?.inputParam = strSource
        book.bookLink = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.bookLink)!)
        
        self.webSources?.parsingPatterns?.getCategoryBooksResult?.imageSrc?.inputParam = strSource
        if(self.webSources?.parsingPatterns?.getCategoryBooksResult?.imageSrc?.inputKey.isEmpty == false)
        {
            self.webSources?.parsingPatterns?.getCategoryBooksResult?.imageSrc?.inputParam = book.value(forKey: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.imageSrc?.inputKey)!) as! String
        }
        book.imgSrc = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.imageSrc)!)
        
        self.webSources?.parsingPatterns?.getCategoryBooksResult?.author?.inputParam = strSource
        book.author = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.author)!)
        book.author = BCTBookAnalyzer.dealDatailString(book.author)
        
        
        self.webSources?.parsingPatterns?.getCategoryBooksResult?.memo?.inputParam = strSource
        book.memo = getRetString(byBookParsingItem: (self.webSources?.parsingPatterns?.getCategoryBooksResult?.memo)!)
        book.memo = BCTBookAnalyzer.dealDatailString(book.memo)
        
        
        return book
    }
    
    
    // MARK:- UtilFunction
    
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
    
    func getUseJavascriptFunc(strFunctionName:String,strFuncImp:String,strParams:[String])->String
    {
        var strRet = ""
        let context: JSContext = JSContext()
        context.evaluateScript(strFuncImp)
        let squareFunc = context.objectForKeyedSubscript(strFunctionName)
        strRet = (squareFunc?.call(withArguments: strParams).toString())!
        return strRet
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
    
    
    func getRetString(byBookParsingItem bookparsingitem:BookParsingItem) -> String
    {
        var strRet : String = ""
        if(bookparsingitem.inputKey.isEmpty == true)
        {
            strRet = BCTBookAnalyzer.getStrGroup1(bookparsingitem.inputParam, pattern: bookparsingitem.parsing)
        }
        else
        {
            strRet = bookparsingitem.inputParam
        }
        if(bookparsingitem.parsingFuntionName.isEmpty == false)
        {
            strRet = self.getUseJavascriptFunc(strFunctionName: bookparsingitem.parsingFuntionName, strFuncImp: (bookparsingitem.parsingFuntion), strParams: [strRet])
        }
        return strRet
        
    }
    
    
    
    
    
}
