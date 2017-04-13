//
//  H23wxEngine.m
//  BookCity
//
//  Created by apple on 16/2/2.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "H23wxEngine.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookAnalyzer.h"

@implementation H23wxEngine

- (BCTSessionManager *)sessionManager {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngineH23Wx];
}

-(void)getSearchBookResult:(BMBaseParam*)baseParam {
    NSString *strKeyWord = baseParam.paramString;
    
    if(baseParam.paramInt < 1) {
        baseParam.paramInt = 1;
    } else {
        baseParam.paramInt++;
    }
    
    NSString *stringPage = [NSString stringWithFormat:@"%ld",(long)baseParam.paramInt];
    
    // FIXME: 这里的keyword在网站被encode了，和我们代码里面encode的不一样
    NSDictionary *dict = @{@"searchkey":strKeyWord,@"page":stringPage,@"ct":@"2097152",@"si":@"52mb.net",@"sts":@"52mb.net"};
    NSString *strUrl = @"/modules/article/search.php";
    
    // MARK:23wx改为post请求了
    [self.sessionManager POST:strUrl parameters:dict success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSMutableArray *bookList = nil;
        
        bookList = [[NSMutableArray alloc]initWithArray:[self getBookListH23wx:responseStr]];
        
        baseParam.resultArray = bookList;
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }

    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         NSLog(@"%@",[error userInfo]);
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(-1,@"",nil);
        }
     }];
}

-(NSArray*)getBookListH23wx:(NSString*)strSource
{
    NSString *strPattern = @"<div class=\"result-item result-game-item\">[\\s\\S]*?</p>\\s*?</div>";
    
//    NSArray* arySource = [BCTBookAnalyzer getBookListBaseStr:strSource pattern:strPattern];
    NSArray* arySource = [strSource matchedStringsWithPattern:strPattern];
    NSMutableArray *bookList = [[NSMutableArray alloc]init];
    
    for (NSString* subStrSource in arySource) {
        BCTBookModel *book = [self getBookModeH23wx:subStrSource];
        [bookList addObject:book];
    }
    
    return bookList;
}

-(BCTBookModel*)getBookModeH23wx:(NSString*)strSource {
    BCTBookModel *book = [BCTBookModel new];
    
    book.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a cpos=\"title\" href=\"\[^\"]*\" title=\"([^\"]*)\""];
    book.imgSrc = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<img src=\"([^\"]*)\""];
    book.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a cpos=\"img\" href=\"([^\"]*)\""];
    
    book.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a cpos=\"author\"[^>]*>([^<]*)</a>"];
    book.author = [book.author trimWithExcludedStrings:@[@" ", @"\r\n"]];
    
    
    book.memo = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<p class=\"result-game-item-desc\">[^.]*..([\\s\\S]*?)</p>"];
    book.memo = [book.memo trimWithExcludedStrings:@[@"<em>", @"</em>"]];

    return book;
}



#pragma mark-  getBookChapterList

-(void)getBookChapterList:(BMBaseParam*)baseParam {
    
    NSString *strUrlParam = baseParam.paramString;
    
    NSString *strUrl = [strUrlParam stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        baseParam.resultArray = [self getChapterList:responseStr url:strUrlParam];
        
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         NSLog(@"%@",[error userInfo]);
         if (baseParam.withresultobjectblock) {
             baseParam.withresultobjectblock(-1,@"",nil);
         }
         
     }];
}


-(NSMutableArray*)getChapterList:(NSString*)strSource url:(NSString*)strUrl {
    
    NSMutableArray *aryChapterList = [NSMutableArray new];
    
    NSArray *results = [strSource matchesWithPattern:@"<td class=\"L\"><a href=\"([^\"]*)\">([^<]*)<\\/a>"];
    for (NSTextCheckingResult *match in results) {
        
        BCTBookChapterModel *bookchaptermodel = [BCTBookChapterModel new];
        
        bookchaptermodel.url = [strSource substringWithRange:[match rangeAtIndex:1]];
        bookchaptermodel.url = [NSString stringWithFormat:@"%@%@",strUrl,bookchaptermodel.url];
        bookchaptermodel.title = [strSource substringWithRange:[match rangeAtIndex:2]];
        bookchaptermodel.hostUrl = self.sessionManager.baseURLString;
        [aryChapterList addObject:bookchaptermodel];
    }
    
    return aryChapterList;
}


#pragma mark-  getBookChapterDetail

-(void)getBookChapterDetail:(BMBaseParam*)baseParam {
    //paramString2 保存chapterDetail url
    NSString *strUrl = baseParam.paramString2;
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    __weak H23wxEngine *weakSelf = self;
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
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
    return [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<dd id=\"contents\">([\\s\\S]*?)</dd>"];
}

#pragma mark-  getCategoryBooksResult

-(void)getCategoryBooksResult:(BMBaseParam*)baseParam {
    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        
        NSMutableArray *bookList = nil;
        
        bookList = [self getBookListFromCategoryH23w:responseStr];
        
        baseParam.resultArray = bookList;
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(0,@"",nil);
        }

    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         NSLog(@"%@",[error userInfo]);
         if (baseParam.withresultobjectblock) {
             baseParam.withresultobjectblock(-1,@"",nil);
         }
         
     }];
}

-(NSMutableArray*)getBookListFromCategoryH23w:(NSString*)strSource {
    NSMutableArray *retAry = [NSMutableArray new];
    
    [[strSource matchedStringsWithPattern:@"<tr bgcolor=\"#FFFFFF\">[\\s\\S]*?</tr>"] enumerateObjectsUsingBlock:^(NSString * _Nonnull matchedString, NSUInteger idx, BOOL * _Nonnull stop) {
        BCTBookModel *bookModel = [self getBookModelFromCategory:matchedString];
        [retAry addObject:bookModel];
    }];
    
    return retAry;
}

-(BCTBookModel*)getBookModelFromCategory:(NSString*)strSource {
    BCTBookModel *bookmodel = [BCTBookModel new];

    bookmodel.bookLink = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"([^\"]*)\" target=\"_blank\">"];
    bookmodel.title = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<td class=\"L\">[\\s\\S]*?</a><a [^>]*>(.*?)</a>"];
    bookmodel.author = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<td class=\"C\">(.*?)</td>[\\s\\S]*?<td class=\"R\">"];
    
    NSArray *aryBookNumber = [bookmodel.bookLink componentsSeparatedByString:@"/"];
    
    NSString *strBookNumber = [aryBookNumber objectAtIndex:[aryBookNumber count]-2];
    
    NSString *strBookNumberFront2 = [strBookNumber substringToIndex:2];
    
    bookmodel.imgSrc = [NSString stringWithFormat:@"http://www.23us.com/files/article/image/%@/%@/%@s.jpg",strBookNumberFront2,strBookNumber,strBookNumber];

    return bookmodel;
}

@end
