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
    
    // MARK:- downloadBook
    func downloadBook(baseParam: BMBaseParam) {
        let book: BCTBookModel? = (baseParam.paramObject as? BCTBookModel)
        if book == nil {
            if (baseParam.withresultobjectblock != nil) {
                baseParam.withresultobjectblock(-1, "数据没有准备好，不要下载", nil)
            }
        }
        
        if(book!.aryChapterList.count>0)
        {
//            downloadImp(bookmodel: book)
            self.downloadPlist(baseParam: baseParam)
        }
        else
        {
            self.getChapters(bookmodel: book!, finish: { () -> (Void) in
                //self.downloadImp(bookmodel: book)
                self.downloadPlist(baseParam: baseParam)
            })
        }
        
    }
    
//    func downloadImp(bookmodel book:BCTBookModel)
//    {
//        let baseparam:BMBaseParam = BMBaseParam()
//        
//        baseparam.paramObject = book
////        baseparam.withresultobjectblock = {(errorId,messge,id)->Void in
////            if(errorId == 0){
////                print("调用成功")
////            }
////            else{
////            }
////            
////        }
////        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
////        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_DOWNLOADPLIST)
////        dicParam.setParam(baseparam)
////        BMControl.sharedInstance().excute(dicParam)
//    }
    
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
//        let dicParam:NSMutableDictionary = NSMutableDictionary.createParamDic()
//        dicParam.setActionID(FSPublicUtil.DEF_ACTIONID_BOOKACTION, strcmd: FSPublicUtil.DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST)
//        dicParam.setParam(baseparam)
        self.getBookChapterList(baseParam: baseparam)
        
        
//        BMControl.sharedInstance().excute(dicParam)
    }
    
    
    func downloadPlist(baseParam: BMBaseParam) {
        let bookmodel: BCTBookModel? = (baseParam.paramObject as? BCTBookModel)
        if bookmodel == nil || bookmodel?.aryChapterList.count == 0 {
            if (baseParam.withresultobjectblock != nil) {
                baseParam.withresultobjectblock(-1, "数据没有准备好，不要下载", nil)
            }
        }
        // Start downloading book
        bookmodel?.finishChapterNumber = 0
        downloadChapterOnePage(baseParam, book: bookmodel!)
    }
    
    func downloadChapterOnePage(_ baseParam: BMBaseParam, book bookmodel: BCTBookModel) {
        let pageSize: Int = 10
        let curPageEnd: Int = bookmodel.finishChapterNumber + pageSize
//        let sessionManager: BCTSessionManager? = self.sessionManager()
        weak var weakSelf: BookMountainEngine? = self
        var i: Int = bookmodel.finishChapterNumber
        while i < curPageEnd && i < bookmodel.aryChapterList.count {
//            if DYMBookDownloadManager.sharedInstance().downloadingBook == nil {
//                break
//            }
            let bookchaptermodel: BCTBookChapterModel? = (bookmodel.aryChapterList[i] as? BCTBookChapterModel)
            i += 1
            //        usleep(100);
            // Get chapter url
            let strUrl: String? = bookchaptermodel?.url
//            strUrl = strUrl?.replacingOccurrences(of: sessionManager?.getBaseUrl(), with: "")
            // completion block
            
            let closure: (_ baseParam:BMBaseParam,_ bookModel: BCTBookModel) -> Void = { (baseParam, bookModel) in
                // code
                bookmodel.finishChapterNumber += 1
                if(baseParam.withresultobjectblock != nil)
                {
                    var strMessage = "downloading";
                    var errorCode = 0
                    if(bookmodel.finishChapterNumber == bookmodel.aryChapterList.count)
                    {
                        if(bookmodel.savePlist())
                        {
                            strMessage = "finished"
                        }
                        else
                        {
                            errorCode = -1
                        }
                        
                    }
                    else
                    {
                        if(bookmodel.finishChapterNumber == curPageEnd) {
                            //[weakSelf downloadChapterOnePage:baseParam book:bookmodel];
                            weakSelf?.downloadChapterOnePage(baseParam, book: bookmodel)
                        }
                    }
                    baseParam.withresultobjectblock(Int32(errorCode), strMessage, nil);
                }
            }
            
            
            Alamofire.request(strUrl!).response{ response in
                
                if(response.error == nil)
                {
                    if let data = response.data, let contentText = String(data: data, encoding: self.getStringEncoding(strEncodingDescribe: (self.webSources!.parsingPatterns!.getBookChapterDetail?.responseEncoding)!))
                    {
                        print("Data: \(contentText)")
                        bookchaptermodel?.htmlContent = self.getChapterContent(strSource: contentText)
                        
                        bookchaptermodel?.content = self.getChapterContentText(strSource: (bookchaptermodel?.htmlContent)!)
                        
                    }

                }
                
                closure(baseParam,bookmodel)
            }

            
        }
    }
    
    
//    -(void)downloadChapterOnePage:(BMBaseParam*)baseParam
//    book:(BCTBookModel*)bookmodel {
//    NSInteger pageSize = 10;
//    NSInteger curPageEnd = bookmodel.finishChapterNumber + pageSize;
//    BCTSessionManager *sessionManager = [self sessionManager];
//    
//    __weak id<BCIBookEngine> weakSelf = self;
//    NSInteger i = bookmodel.finishChapterNumber;
//    while (i < curPageEnd && i < [bookmodel.aryChapterList count]) {
//    
//    if ([DYMBookDownloadManager sharedInstance].downloadingBook == nil) {
//    break;
//    }
//    
//    BCTBookChapterModel* bookchaptermodel = [bookmodel.aryChapterList objectAtIndex:i];
//    i++;
//    //        usleep(100);
//    
//    // Get chapter url
//    NSString *strUrl = bookchaptermodel.url;
//    strUrl = [strUrl stringByReplacingOccurrencesOfString:[sessionManager getBaseUrl] withString:@""];
//    
//    // completion block
//    void (^completionBlock)(BMBaseParam *baseParam, BCTBookModel *bookmodel) = ^void(BMBaseParam *baseParam, BCTBookModel *bookmodel) {
//    
//    bookmodel.finishChapterNumber++;
//    
//    if (baseParam.withresultobjectblock) {
//    if (bookmodel.finishChapterNumber == [bookmodel.aryChapterList count]) {
//    
//    [bookmodel savePlist];
//    
//    baseParam.withresultobjectblock(0, @"finished", nil);
//    
//    } else {
//    
//    if(bookmodel.finishChapterNumber == curPageEnd) {
//    [weakSelf downloadChapterOnePage:baseParam book:bookmodel];
//    }
//    
//    baseParam.withresultobjectblock(0, @"downloading", nil);
//    }
//    }
//    };
//    
//    // Start downloading
//    id task = [sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
//    
//    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
//    
//    //modify by fx
//    if(responseStr.length==0)
//    {
//    responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//    }
//    
//    bookchaptermodel.htmlContent = [weakSelf getChapterContent:responseStr];
//    bookchaptermodel.content = [weakSelf getChapterContentText:bookchaptermodel.htmlContent];
//    
//    completionBlock(baseParam, bookmodel);
//    
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//    
//    NSLog(@"%@",[error userInfo]);
//    
//    completionBlock(baseParam, bookmodel);
//    }];
//    
//    [[DYMBookDownloadManager sharedInstance] registerDownloadingTask:task];
//    }
//    }
    
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
