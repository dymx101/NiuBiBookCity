//
//  SiKushuEngine.m
//  BookCity
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "SiKushuEngine.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookAnalyzer.h"

@interface SiKushuEngine ()
@property (nonatomic, strong) NSMutableDictionary *keywordPageCounts;
@end

@implementation SiKushuEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keywordPageCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BCTSessionManager *)sessionManager {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngineSiKuShuNet];
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

// delay the search of this engine
-(void)getSearchBookResult:(BMBaseParam*)baseParam {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doGetSearchBookResult:baseParam];
    });
}

-(void)doGetSearchBookResult:(BMBaseParam*)baseParam {

    if (![self canSearchWithBookParam:baseParam]) {
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
        return;
    }
    
    NSString *strSource = baseParam.paramString;
    NSString *strKeyWord = [strSource URLEncodedStringGB_18030_2000];

    NSString *strUrl = [NSString stringWithFormat:@"/modules/article/search.php?searchkey=%@&searchtype=articlename&submit=%@&page=%ld",strKeyWord,@"%CB%D1%CB%F7",(long)baseParam.paramInt];
    
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
//        NSLog(@"Siku Search: %@", task.currentRequest.URL.absoluteString);
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
        NSMutableArray *bookList = nil;
        
        if([BCTBookAnalyzer firstMatchInSoure:responseStr pattern:@"<h1 class=\"f20h\">"].length > 0)
        {
            BCTBookModel *oneBook = [self getBookModeSiKuShuForOne:responseStr];
            bookList = [[NSMutableArray alloc]initWithCapacity:2];
            [bookList addObject:oneBook];
        } else {
            NSArray *boollistSiKuShu = [self getBookListSiKuShu:responseStr];
            
            if ([boollistSiKuShu count]>0) {
                bookList = [[NSMutableArray alloc]initWithArray:boollistSiKuShu];
            }
        }
        
        baseParam.resultArray = bookList;
        
        // 获取总页数
        NSString *pageStr = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<em id=\"pagestats\">([^<]*)</em>"];
        NSArray *pageInfo = [pageStr componentsSeparatedByString:@"/"];
        if (pageInfo.count == 2) {
            [self.keywordPageCounts setValue:@([pageInfo.lastObject integerValue]) forKey:strSource];
        }
        
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


-(NSArray*)getBookListSiKuShu:(NSString*)strSource
{
    NSString *strPattern = @"<tr>[\\s\\S]*?</tr>";
    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
    NSArray* arySource = [strSource matchedStringsWithPattern:strPattern];
    NSMutableArray *bookList = [[NSMutableArray alloc]init];
    
    for (NSString* subStrSource in arySource) {
        BCTBookModel *book = [self getBookModeSiKuShu:subStrSource];
        if (book) {
            [bookList addObject:book];
        }
    }
    
    return bookList;
}

-(BCTBookModel*)getBookModeSiKuShu:(NSString*)strSource {
    BCTBookModel *book = [BCTBookModel new];

    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"[^\"]*\"\\s*>([^<]*)</a>"];
    
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"([^\"]*)\"\\s*target[^>]*>[^<]*</a>"];
    
    if (book.title.length <= 0 || book.bookLink.length <= 0) {
        return nil;
    }
    
    book.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<td class=\"odd\">([^<]*)</td>"];
    
    NSArray *aryBookNumber = [book.bookLink componentsSeparatedByString:@"/"];
    if (aryBookNumber.count > 1) {
        NSString *strBookNumber = [aryBookNumber objectAtIndex:[aryBookNumber count]-2];
        
        if (strBookNumber.length > 2) {
            NSString *strBookNumberFront2 = [strBookNumber substringToIndex:2];
            
            book.imgSrc = [NSString stringWithFormat:@"http://www.sikushu.com/files/article/image/%@/%@/%@s.jpg",strBookNumberFront2,strBookNumber,strBookNumber];
            return book;
        }
    }
    
    return nil;
}



//getBookImg
-(NSString*)getBookImgStr7788:(NSString*)strSource
{
    NSString *strPattern1 = @"<img alt=\".*?\" src=\".*?\" />";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"src=\".*?\"";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"src=", @"\""]];
    
}

-(NSString*)getBookLink7788:(NSString*)strSource
{
    NSString *strPattern1 = @"<a href=\".*?\"><img";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"href=\".*?\"";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"href=", @"\""]];
    
}



-(NSString*)getBookTitle7788:(NSString*)strSource
{
    NSString *strPattern1 = @"<img alt=\".*?\" src=\".*?\" />";
    
    NSString *strResult = [BCTBookAnalyzer firstMatchInSoure:strSource pattern:strPattern1];
    
    NSString *strPattern2 = @"alt=\".*?\"";
    
    strResult = [BCTBookAnalyzer firstMatchInSoure:strResult pattern:strPattern2];
    
    return [strResult trimWithExcludedStrings:@[@"alt=", @"\""]];
    
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
    
    NSString *pattern = @"<li>[^<]*<a href=\"[^\"]*\"\\s*>([^<]*)</a>[^<]*</li>";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:strSource options:0 range:NSMakeRange(0, strSource.length)];
    for (NSTextCheckingResult *match in results) {
        
        BCTBookChapterModel *bookchaptermodel = [BCTBookChapterModel new];
        NSString* substringForMatch = [strSource substringWithRange:match.range];
//        NSLog(@"chapter list: %@",substringForMatch);

        NSString *strPatternListDetail = @"<a href=\"([^\"]*)\">([^<]*)</a>";
        NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:strPatternListDetail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchs = [regular matchesInString:substringForMatch options:0 range:NSMakeRange(0, substringForMatch.length)];
        
            if ([matchs count]>0) {
        
                NSTextCheckingResult *match2 = [matchs objectAtIndex:0];
        
                
                bookchaptermodel.url = [substringForMatch substringWithRange:[match2 rangeAtIndex:1]];
                
                
                NSString* strChapterUrlBase = [strUrl stringByDeletingLastPathComponent];
                bookchaptermodel.url = [NSString stringWithFormat:@"%@/%@",strChapterUrlBase,bookchaptermodel.url];
                
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
    __weak SiKushuEngine *weakSelf = self;
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

-(NSString*)getChapterContent:(NSString*)strSource {
    NSString *strContent = @"";
    strContent = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<div class=\"readpage_body_nr_01_a3\">\n<div id=\"content\">([\\S\\s]*?)</div>"];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"(四库书www.sikushu.com)" withString:@""];
    
    NSString *strScriptPattern = @"\\[最快的更新.*?\\]";
    NSString *strScript = [BCTBookAnalyzer firstMatchInSoure:strContent pattern:strScriptPattern];
    
    strContent = [strContent stringByReplacingOccurrencesOfString:strScript withString:@""];
    
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
    bookmodel.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a class=\"ui_btn2\" href=\"([^\"]*)\" target=\"_blank\" title=\"目录\">"];
    bookmodel.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"[^\"]*\" alt=\"([^\"]*)\"/>"];
    bookmodel.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<p>([\\S\\s]*?)</p>"];
    bookmodel.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"作者：([^<]*)</a>"];
    
    return bookmodel;
}


@end
