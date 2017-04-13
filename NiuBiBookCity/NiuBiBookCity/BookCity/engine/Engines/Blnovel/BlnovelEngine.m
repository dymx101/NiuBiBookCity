//
//  SiKushuEngine.m
//  BookCity
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BlnovelEngine.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookAnalyzer.h"

@interface BlnovelEngine ()
@property (nonatomic, strong) NSMutableDictionary *keywordPageCounts;
@end

@implementation BlnovelEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keywordPageCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BCTSessionManager *)sessionManager {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngineBlnovel];
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
//    strSource = @"风弄";
    NSString *strKeyWord = [strSource URLEncodedStringGB_18030_2000];
//        NSString *strKeyWord = strSource;

    NSString *strUrl = [NSString stringWithFormat:@"/search.php?searchkey=%@&searchtype=articlename&sqtype=1&bysort=0&page=%ld",strKeyWord,(long)baseParam.paramInt];
    
//    NSString *strUrl = @"/search.php";
//    NSDictionary *dict = @{@"searchkey":strKeyWord,@"searchtype":@"articlename",@"sqtype":@"1"};
    

    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
//        NSLog(@"Siku Search: %@", task.currentRequest.URL.absoluteString);
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
        
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
        
        NSString *strBookCount = [BCTBookAnalyzer firstMatchGroupInSoure:responseStr pattern:@"共搜索到(.*?)本"];
        if(strBookCount.length>0){
        int intBookCount = [strBookCount intValue];
        int pageSize = 20;
        int pageCount = intBookCount/pageSize;
        if (intBookCount%pageSize > 0 || intBookCount<pageSize) {
            pageCount++;
        }
//        else
//        {
//            
//        }
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
    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div class=\"pic\"[^\"]*\"([^\"]*)\""];
    
    return book;
}


-(NSArray*)getBookList:(NSString*)strSource
{
    NSString *strPattern = @"<div class=\"book\">[\\s\\S]*?<dd class=\"book_intro\">[\\s\\S]*?</dd>";
    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
    NSArray* arySource = [strSource matchedStringsWithPattern:strPattern];
    NSMutableArray *bookList = [[NSMutableArray alloc]init];
    
    for (NSString* subStrSource in arySource) {
        BCTBookModel *book = [self getBookMode:subStrSource];
        [bookList addObject:book];
    }
    
    return bookList;
}

-(BCTBookModel*)getBookMode:(NSString*)strSource
{
    BCTBookModel *book = [BCTBookModel new];
    
    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"</em>[\\s\\S].*?<a target=\"_blank\" href=\".*[^\\\"]\" >([\\s\\S].*?)</a>"];
    book.title = [book.title trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"</em>[\\s\\S].*?<a target=\"_blank\" href=\"(.*[^\\\"])\" >[\\s\\S].*?</a>"];
    book.bookLink = [NSString stringWithFormat:@"http://www.blnovel.com%@",book.bookLink];

    book.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<dd class=\"auth\">(.*[^<])</dd>"];
    book.title = [book.author trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img width=\".*[^\"]\" height=\".*[^\"]\" src=\"(.*[^\"])\""];
    book.imgSrc = [NSString stringWithFormat:@"http://www.blnovel.com%@",book.imgSrc];
    
    book.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<dd class=\"book_intro\">(.*?)</dd>"];
    book.memo = [book.memo trimWithExcludedStrings:@[@"<em>", @"</em>"]];
    
    return book;
}


-(NSString*)getBookMemo7788:(NSString*)strSource
{
    NSString *strPattern1 = @"<span>状态：.*?<a href=\".*?\" class=\"sread\">开始阅读";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"<br />.*?<a";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"<br />", @"<a"]];
    
}

//获取作者
-(NSString*)getBookAuthor7788:(NSString*)strSource
{
    NSString *strPattern1 = @"作者：</span><a href=\".*?\">.*?</a>";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"\">.*?</a>";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"</a>", @">", @"\""]];
    
}

//cateogryName
//获取分类
-(NSString*)getBookCateogryName7788:(NSString*)strSource
{
    NSString *strPattern1 = @"分类：</span><a href=\".*?\">.*?</a>";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"\">.*?</a>";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"</a>", @">", @"\""]];
}


#pragma mark-  getBookChapterList

-(void)getBookChapterList:(BMBaseParam*)baseParam
{
    //NSString *strUrlParam = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    NSString *strUrlParam = baseParam.paramString;
    
    NSString *strUrl = [strUrlParam stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
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


-(NSMutableArray*)getChapterList:(NSString*)strSource
                             url:(NSString*)strUrl
{
    
    NSMutableArray *aryChapterList = [NSMutableArray new];
    
    NSString *pattern = @"<td class=\"ccss\">[\\s\\S]*?</td>";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:strSource options:0 range:NSMakeRange(0, strSource.length)];
    for (NSTextCheckingResult *match in results) {
        
        BCTBookChapterModel *bookchaptermodel = [BCTBookChapterModel new];
        NSString* substringForMatch = [strSource substringWithRange:match.range];
//        NSLog(@"chapter list: %@",substringForMatch);

             //NSString *strPatternListDetail = @"<a href=\"(.*[^\"])\">(.*[^<])</a>";
        NSString *strPatternListDetail = @"<a href=\"([^\"]*)\">([^<]*)</a>";
        NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:strPatternListDetail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchs = [regular matchesInString:substringForMatch options:0 range:NSMakeRange(0, substringForMatch.length)];
        
            if ([matchs count]>0) {
        
                NSTextCheckingResult *match2 = [matchs objectAtIndex:0];
        
                
                bookchaptermodel.url = [substringForMatch substringWithRange:[match2 rangeAtIndex:1]];
                
                
//                NSString* strChapterUrlBase = [strUrl stringByDeletingLastPathComponent];
                bookchaptermodel.url = [NSString stringWithFormat:@"%@/%@",strUrl,bookchaptermodel.url];
                
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
    __weak BlnovelEngine *weakSelf = self;
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
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
    NSString *strContent = @"";
    
    strContent = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div id=\"content\">([\\S\\s]*?)</div>"];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"<u>如果您喜欢本作品，请记得点下方的“投它一票”，以及多发表评论，这是对作者最好的鼓励!</u>" withString:@""];

    return strContent;
}

#pragma mark-  getCategoryBooksResult

-(void)getCategoryBooksResult:(BMBaseParam*)baseParam
{
    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        //NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
        
        
        NSMutableArray *bookList = nil;

        NSString *strListMain = [self getMainListContent:responseStr];
        
        bookList = [self getBookListFromCategorySiku:strListMain];
        
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
