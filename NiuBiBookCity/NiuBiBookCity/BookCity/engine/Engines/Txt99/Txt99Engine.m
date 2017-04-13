//
//  SiKushuEngine.m
//  BookCity
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "Txt99Engine.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookAnalyzer.h"

@interface Txt99Engine ()
@property (nonatomic, strong) NSMutableDictionary *keywordPageCounts;
@end

@implementation Txt99Engine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keywordPageCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BCTSessionManager *)sessionManager {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngineTxt99];
}

- (BCTSessionManager *)sessionManagerZhanneiBaidu {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngineZhanneiBaidu];
}


-(BOOL)canSearchWithBookParam:(BMBaseParam*)baseParam {
    if (baseParam.paramString.length <= 0) {
        return NO;
    }
    
    NSInteger pageCount = [self.keywordPageCounts[baseParam.paramString] integerValue];
    NSInteger pageIndex = baseParam.paramInt;
    
    if (pageIndex != 1 && pageIndex > pageCount) {
        return NO;
    }
    
    return YES;
}

-(void)getSearchBookResult:(BMBaseParam*)baseParam {
    
    if (![self canSearchWithBookParam:baseParam]) {
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
        return;
    }
    
    NSString *strSource = baseParam.paramString;
//    strSource = @"盗墓";
//    NSString *strKeyWord = [strSource URLEncodedStringGB_18030_2000];
        NSString *strKeyWord = strSource;

    baseParam.paramInt--;
    NSString *strUrl = [NSString stringWithFormat:@"/cse/search?q=%@&p=%ld&s=10722981113312165527",strKeyWord,(long)baseParam.paramInt];
    
//    NSString *strUrl = @"/search.php";
//    NSDictionary *dict = @{@"searchkey":strKeyWord,@"searchtype":@"articlename",@"sqtype":@"1"};
    

    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[self sessionManagerZhanneiBaidu] GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
//        NSLog(@"Siku Search: %@", task.currentRequest.URL.absoluteString);
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        
        //共搜索到74本
        
        NSMutableArray *bookList = nil;
        
//        NSString *strBookNumber =
        
//        if([BCTBookAnalyzer getStr:responseStr pattern:@"<h1 class=\"f20h\">"].length > 0)
//        {
//            BCTBookModel *oneBook = [self getBookModeSiKuShuForOne:responseStr];
//            bookList = [[NSMutableArray alloc]initWithCapacity:2];
//            [bookList addObject:oneBook];
//        }
//        else
        {
            NSArray *boollistBlnovel = [self getBookList:responseStr];
            
            if ([boollistBlnovel count]>0) {
                bookList = [[NSMutableArray alloc]initWithArray:boollistBlnovel];
            }
        }
        
        baseParam.resultArray = bookList;
        
        NSString *strBookCount = [BCTBookAnalyzer firstMatchGroupInSoure:responseStr pattern:@"为您找到相关结果(.*?)个"];
        if(strBookCount.length > 0) {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSInteger intBookCount = [[formatter numberFromString:strBookCount] integerValue];
            
            NSInteger pageSize = 10;
            NSInteger pageCount = intBookCount/pageSize;
            if (intBookCount%pageSize > 0 || intBookCount<pageSize) {
                pageCount++;
            }

            [self.keywordPageCounts setValue:@(pageCount) forKey:strSource];
        }
        // 获取总页数
//        NSString *pageStr = [BCTBookAnalyzer getStrGroup1:responseStr pattern:@"<em id=\"pagestats\">([^<]*)</em>"];
//        NSArray *pageInfo = [pageStr componentsSeparatedByString:@"/"];
//        if (pageInfo.count == 2) {
//            [self.keywordPageCounts setValue:@([pageInfo.lastObject integerValue]) forKey:strSource];
//        }
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         NSLog(@"%@",[error userInfo]);
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(1,@"",nil);
        }
     }];
}

//整个HTML一本书
-(BCTBookModel*)getBookModeSiKuShuForOne:(NSString*)strSource {
    BCTBookModel *book = [BCTBookModel new];
    
    NSString *strPatternAuthorAndTitle = @"<h1 class=\"f20h\">([^<]*)<em>([^<]*)</em></h1>";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:strPatternAuthorAndTitle options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchs = [regular matchesInString:strSource options:0 range:NSMakeRange(0, strSource.length)];
    
        if ([matchs count]>0) {
    
            NSTextCheckingResult *match = [matchs objectAtIndex:0];
    
            book.title = [strSource substringWithRange:[match rangeAtIndex:1]];
            book.author = [strSource substringWithRange:[match rangeAtIndex:2]];
            
            //作者：
            book.author = [book.author stringByReplacingOccurrencesOfString:@"作者：" withString:@""];
        }
    
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"([^\"]*)\" title=\"开始阅读\"><span>开始阅读</span>"];
//    <div class="pic"[^\"]*\"([^\"]*)\"
    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div class=\"pic\"[^\"]*\"([^\"]*)\""];
    return book;
}


-(NSArray*)getBookList:(NSString*)strSource
{
    NSString *strPattern = @"<div class=\"result-item result-game-item\">[\\s\\S]*?</p>\\s*?</div>";
    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
    NSArray* arySource = [strSource matchedStringsWithPattern:strPattern];
    NSMutableArray *bookList = [[NSMutableArray alloc]init];
    
    for (NSString* subStrSource in arySource) {
        BCTBookModel *book = [self getBookMode:subStrSource];
        [bookList addObject:book];
    }
    
    return bookList;
}

-(NSArray*)getBookListCategory:(NSString*)strSource
{
    NSString *strPattern = @"<div class=\"listbg\">[\\s\\S]*?</div>";
    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
    NSArray* arySource = [strSource matchedStringsWithPattern:strPattern];
    NSMutableArray *bookList = [[NSMutableArray alloc]init];
    
    for (NSString* subStrSource in arySource) {
        BCTBookModel *book = [self getBookModeCategory:subStrSource];
        [bookList addObject:book];
    }
    
    return bookList;
}

-(BCTBookModel*)getBookModeCategory:(NSString*)strSource
{
    BCTBookModel *book = [BCTBookModel new];
    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"[^\"]*\" title=\"([^\"]*)\" target=\"_blank\""];
    book.title = [book.title trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"([^\"]*)\" title=\"([^\"]*)\""];
    book.bookLink = [book.bookLink stringByReplacingOccurrencesOfString:@"/txt/" withString:@"/readbook/"];
    
    book.author = @"";

    book.imgSrc = [self dealBookImageCategory:book.bookLink];
    
    book.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div style=\"padding[^\"]*\">([\\s\\S]*?)</div>"];
    book.memo = [book.memo trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    
    return book;
}


-(NSString*)dealBookImageCategory:(NSString*)strSource
{
//    NSArray *array = [strSource componentsSeparatedByString:@"/"];
    
    
    
//    NSString *strResult = [NSString stringWithFormat:@"%@.html", [array objectAtIndex:0]];
    
//    NSString *strResult = [strSource stringByReplacingOccurrencesOfString:@"/txt/" withString:@"/readbook/"];
    NSString *strResult;
    
    NSArray *aryBookHtml = [strSource componentsSeparatedByString:@"/"];
    
    NSString *strBookHtml = [aryBookHtml objectAtIndex:[aryBookHtml count]-1];
    
    NSArray *aryBookNumber = [strBookHtml componentsSeparatedByString:@"."];
    
    NSString *strBookNumber = [aryBookNumber objectAtIndex:0];
    
    NSString *strBookNumberFront2 = [strBookNumber substringToIndex:2];
    
    //http://www.23wx.com/files/article/image/59/59945/59945s.jpg
    //http://img.txt99.cc/Cover/37/37995.jpg
strResult = [NSString stringWithFormat:@"http://img.txt99.cc/Cover/%@/%@.jpg",strBookNumberFront2,strBookNumber];
    
    
    
    return strResult;
}


//-(NSString*)dealBookLinkCategory:(NSString*)strSource
//{
////    NSArray *array = [strSource componentsSeparatedByString:@"_"];
////    
////    ;
////    
////    NSString *strResult = [NSString stringWithFormat:@"%@.html", [array objectAtIndex:0]];
//    
//    NSString *strResult = [strSource stringByReplacingOccurrencesOfString:@"/txt/" withString:@"/readbook/"];
//    
//    return strResult;
//}

-(BCTBookModel*)getBookMode2:(NSString*)strSource {
    BCTBookModel *book = [BCTBookModel new];
    
    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource
                                                      pattern:@"<a cpos=\"title\" href=\"\[^\"]*\" title=\"([^\"]*)\""];
    
    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"([^\"]*)\""];
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a cpos=\"img\" href=\"([^\"]*)\""];
    
    book.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"作者：</span>([\\s\\S]*?)</span>"];
    book.author = [book.author stringByReplacingOccurrencesOfString:@" " withString:@""];
    book.author = [book.author stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    
    book.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource
                                                     pattern:@"<p class=\"result-game-item-desc\">[^.]*..([\\s\\S]*?)</p>"];
    book.memo = [book.memo stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    book.memo = [book.memo stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    
    return book;
}

-(BCTBookModel*)getBookMode:(NSString*)strSource {
    BCTBookModel *book = [BCTBookModel new];
    
    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"[^\"]*\" alt=\"([^\"]*)\""];
    book.title = [book.title trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a cpos=\"newchapter\" href=\"([^\"]*)\" class=\"result-game-item-info-tag-item\" target=\"_blank\">"];
    book.bookLink = [NSString stringWithFormat:@"%@.html", [book.bookLink componentsSeparatedByString:@"_"].firstObject];
    
    book.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"作者：</span>[\\s\\S]*?<span>([\\s\\S]*?)</span>"];
    book.author = [book.author trimWithExcludedStrings:@[@" ", @"\r\n", @"<em>", @"</em>"]];

    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"([^\"]*)\""];
    
    book.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<p class=\"result-game-item-desc\">([\\s\\S]*?)</p>"];
    book.memo = [book.memo trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    return book;
}

-(NSString*)getBookMemo7788:(NSString*)strSource
{
    NSString *strPattern1 = @"<span>状态：.*?<a href=\".*?\" class=\"sread\">开始阅读";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"<br />.*?<a";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    strResult = [strResult stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"<a" withString:@""];
    
    return strResult;
    
}

//获取作者
-(NSString*)getBookAuthor7788:(NSString*)strSource
{
    NSString *strPattern1 = @"作者：</span><a href=\".*?\">.*?</a>";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"\">.*?</a>";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    
    strResult = [strResult stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
    strResult = [strResult stringByReplacingOccurrencesOfString:@">" withString:@""];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strResult;
    
}

//cateogryName
//获取分类
-(NSString*)getBookCateogryName7788:(NSString*)strSource
{
    NSString *strPattern1 = @"分类：</span><a href=\".*?\">.*?</a>";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"\">.*?</a>";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    
    strResult = [strResult stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
    strResult = [strResult stringByReplacingOccurrencesOfString:@">" withString:@""];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strResult;
    
}


#pragma mark-  getBookChapterList

-(void)getBookChapterList:(BMBaseParam*)baseParam
{
    //NSString *strUrlParam = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    NSString *strUrlParam = baseParam.paramString;
    
    NSString *strUrl = [strUrlParam stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        baseParam.resultArray = [self getChapterList:responseStr url:strUrlParam];
        
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error)
     {
         NSLog(@"%@",[error userInfo]);
         if (baseParam.withresultobjectblock) {
             baseParam.withresultobjectblock(-1,@"",nil);
         }
         
     }];
}


-(NSMutableArray*)getChapterList:(NSString*)strSource url:(NSString*)strUrl {

    strSource = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div class=\"read_list\">([\\s\\S]*?)</div>"];
    
    
    NSMutableArray *aryChapterList = [NSMutableArray new];
    
    NSString *pattern = @"<a href=\"[^\"]*\" title=\"[^\"]*\">";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:strSource options:0 range:NSMakeRange(0, strSource.length)];
    for (NSTextCheckingResult *match in results) {
        
        BCTBookChapterModel *bookchaptermodel = [BCTBookChapterModel new];
        NSString* substringForMatch = [strSource substringWithRange:match.range];
//        NSLog(@"chapter list: %@",substringForMatch);

             //NSString *strPatternListDetail = @"<a href=\"(.*[^\"])\">(.*[^<])</a>";
        NSString *strPatternListDetail = @"<a href=\"([^\"]*)\" title=\"([^\"]*)\">";
        NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:strPatternListDetail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchs = [regular matchesInString:substringForMatch options:0 range:NSMakeRange(0, substringForMatch.length)];
        
            if ([matchs count]>0) {
        
                NSTextCheckingResult *match2 = [matchs objectAtIndex:0];
        
                
                bookchaptermodel.url = [substringForMatch substringWithRange:[match2 rangeAtIndex:1]];
                
                
//                NSString* strChapterUrlBase = [strUrl stringByDeletingLastPathComponent];
//                bookchaptermodel.url = [NSString stringWithFormat:@"%%@",strUrl,bookchaptermodel.url];
                
                bookchaptermodel.title = [substringForMatch substringWithRange:[match2 rangeAtIndex:2]];
            }
        bookchaptermodel.hostUrl = self.sessionManager.baseURLString;
        [aryChapterList addObject:bookchaptermodel];
    }
    
    
    
    
    return aryChapterList;
    
    
    
    
}


#pragma mark-  getBookChapterDetail

-(void)getBookChapterDetail:(BMBaseParam*)baseParam
{
    //paramString2 保存chapterDetail url
    NSString *strUrl = baseParam.paramString2;
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    //    __weak BMBaseParam *weakBaseParam = baseParam;
    __weak Txt99Engine *weakSelf = self;
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
//        NSLog(@"%@",responseStr);
        baseParam.resultString = [weakSelf getChapterContent:responseStr];
        
        BCTBookChapterModel* bookchaptermodel = (BCTBookChapterModel*)baseParam.paramObject;
        bookchaptermodel.content = [baseParam.resultString trimHtmlContent];
        bookchaptermodel.htmlContent = baseParam.resultString;
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error)
     {
         NSLog(@"%@",[error userInfo]);
         if (baseParam.withresultobjectblock) {
             baseParam.withresultobjectblock(-1,@"",nil);
         }
         
     }];
}

-(NSString*)getChapterContent:(NSString*)strSource
{
    NSString *strContent = [BCTBookAnalyzer firstMatchGroupInSoure:strSource
                                            pattern:@"<div id=\"view_content_txt\">([\\s\\S]*?)<div class=\"view_page\">"];
   
    NSString *strDeclaration = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"(声明：本书为久久小说网[\\s\\S]*?)作者："];
  
    if(strDeclaration.length > 0) {
        strContent = [strContent stringByReplacingOccurrencesOfString:strDeclaration withString:@""];
    }
    
    return strContent;
}

#pragma mark-  getCategoryBooksResult

-(void)getCategoryBooksResult:(BMBaseParam*)baseParam
{
    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        //NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
        
        
//        NSMutableArray *bookList = nil;

//        NSString *strListMain = [self getMainListContent:responseStr];
        
//        bookList = [self getBookListFromCategorySiku:strListMain];
        
        
        NSMutableArray *bookList = nil;

        NSArray *boollistnovel = [self getBookListCategory:responseStr];
            
        if ([boollistnovel count]>0) {
                bookList = [[NSMutableArray alloc]initWithArray:boollistnovel];
            }
        
     
        baseParam.resultArray = bookList;

        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error)
     {
         NSLog(@"%@",[error userInfo]);
         if (baseParam.withresultobjectblock) {
             baseParam.withresultobjectblock(-1,@"",nil);
         }
         
     }];
}

-(NSString*)getMainListContent:(NSString*)strSource
{
    NSString *strRet = @"";
    strRet = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:@"<ul class=\"list_box1\">[\\S\\s]*?</ul>"];
    
    return strRet;
}

-(NSMutableArray*)getBookListFromCategorySiku:(NSString*)strSource
{
    NSMutableArray *retAry = [NSMutableArray new];
    
//    NSString *strPattern = @"<li>[\\S\\s]*?</li>";
    
    [[strSource matchedStringsWithPattern:@"<li>[\\S\\s]*?</li>"] enumerateObjectsUsingBlock:^(NSString * _Nonnull matchedString, NSUInteger idx, BOOL * _Nonnull stop) {
        BCTBookModel *bookModel = [self getBookModelFromCategory:matchedString];
        [retAry addObject:bookModel];
    }];
    
    return retAry;
}

-(BCTBookModel*)getBookModelFromCategory:(NSString*)strSource
{
    BCTBookModel *bookmodel = [BCTBookModel new];
    bookmodel.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"([^\"]*)\""];
    bookmodel.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"最新章节：<a href=\"([^\"]*)\""];
    bookmodel.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"[^\"]*\" alt=\"([^\"]*)\"/>"];
    bookmodel.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<p>([\\S\\s]*?)</p>"];
    bookmodel.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"作者：([^<]*)</a>"];
    
    return bookmodel;
}


@end
