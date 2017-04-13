//
//  XiaoShuo7788Engine.m
//  BookCity
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "XiaoShuo7788Engine.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookAnalyzer.h"

@implementation XiaoShuo7788Engine


- (BCTSessionManager *)sessionManager {
    return [BCTSessionManager sessionManagerWithEngineType:kBCTBookEngine7788];
}

-(void)getBookChapterDetail:(BMBaseParam*)baseParam
{
    //paramString2 保存chapterDetail url
    NSString *strUrl = baseParam.paramString2;
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];

    __weak XiaoShuo7788Engine *weakSelf = self;
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

-(NSString*)getChapterContent:(NSString*)strSource
{
    NSString *strContent = @"";
    NSString *strPattern = @"<div id=\"content\">([\\s\\S]*?)</div>";
    strContent = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:strPattern];
    
    return strContent;
}

-(void)getCategoryBooksResult:(BMBaseParam*)baseParam {
    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        NSMutableArray *bookList = [[NSMutableArray alloc]init];
        
        NSArray *ary7788 = [self getBookList7788:responseStr];
        for (NSTextCheckingResult *match in ary7788) {
            NSString* substringForMatch = [responseStr substringWithRange:match.range];
//            NSLog(@"Extracted URL: %@",substringForMatch);
            //            [arrayOfURLs addObject:substringForMatch];
            BCTBookModel *bookModel = [self getBookModel7788:substringForMatch webContent:responseStr];
            [bookList addObject:bookModel];
            
//            NSLog(@"========================================");
//            NSLog(@"%@",bookModel.title);
//            NSLog(@"%@",bookModel.imgSrc);
//            NSLog(@"%@",bookModel.bookLink);
//            NSLog(@"%@",bookModel.memo);
        }
        
        
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


-(void)getSearchBookResult:(BMBaseParam*)baseParam
{
    
//    NSString *strSource = @"校花";
    NSString *strSource = baseParam.paramString;
    NSString *strKeyWord = [strSource URLEncodedStringGB_18030_2000];
    NSString *stringPage = [NSString stringWithFormat:@"%ld",(long)baseParam.paramInt];

    NSDictionary *dict = @{ @"Search":strKeyWord, @"t":stringPage};
    
    NSString *strUrl = [NSString stringWithFormat:@"modules/article/search.php?searchkey=%@&t=1&page=%ld" ,strKeyWord,(long)baseParam.paramInt];
    [self.sessionManager GET:strUrl parameters:dict success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];

        NSMutableArray *bookList = nil;
        if ([responseStr rangeOfString:@"提示：没有找到符合条件的小说"].location == NSNotFound) {
            
            bookList = [[NSMutableArray alloc] init];
            
            NSArray *ary7788 = [self getBookList7788:responseStr];
            for (NSTextCheckingResult *match in ary7788) {
                NSString* substringForMatch = [responseStr substringWithRange:match.range];
//                NSLog(@"Extracted URL: %@",substringForMatch);
                //            [arrayOfURLs addObject:substringForMatch];
                BCTBookModel *bookModel = [self getBookModel7788:substringForMatch webContent:responseStr];
                [bookList addObject:bookModel];
                
//                NSLog(@"========================================");
//                NSLog(@"%@",bookModel.title);
//                NSLog(@"%@",bookModel.imgSrc);
//                NSLog(@"%@",bookModel.bookLink);
//                NSLog(@"%@",bookModel.memo);
            }
            
        } else {
            NSLog(@"提示：没有找到符合条件的小说");
        }
        
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

-(NSArray*)getBookList7788:(NSString*)strSource
{
    return [strSource matchesWithPattern:@"<div class=\"ml212\">[\\s\\S]*?</div>"];
}

-(NSString*)getBookImgStr7788:(NSString*)strSource
                    bookTitle:(NSString*)strBookTitle
{
    NSString *strPattern1 =  [NSString stringWithFormat: @"<img alt=\"%@\" src=\"([^\"]*)\" />",strBookTitle];
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:strPattern1]; //[BCTBookAnalyzer getStrGroup1:strSource pattern:strPattern1];
    return strResult;
    
}

-(NSString*)getBookLink7788:(NSString*)strSource
{
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"([^\"]*)\" class=\"a14\">"];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"book" withString:@"read"];
    
    NSString *baseURL = self.sessionManager.baseURLString;
    if (baseURL.length > 1 && [strResult rangeOfString:baseURL].location == NSNotFound) {
        strResult = [[baseURL substringToIndex:baseURL.length - 1] stringByAppendingString:strResult];
    }
    
    return strResult;
    
}



-(NSString*)getBookTitle7788:(NSString*)strSource
{
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<a href=\"[^\"]*\" class=\"a14\">([^<]*)"];
    
    return strResult;
    
}

-(NSString*)getBookMemo7788:(NSString*)strSource
{
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<dd>([^<]*)"];
    
    return strResult;
    
}

//获取作者
-(NSString*)getBookAuthor7788:(NSString*)strSource
{
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<span>作者：</span><a href=\"[^\"]*\">([^<]*)"];
    
    return strResult;
    
}

//cateogryName
//获取分类
-(NSString*)getBookCateogryName7788:(NSString*)strSource
{
    NSString *strResult = [BCTBookAnalyzer firstMatchGroupInSoure:strSource pattern:@"<span>分类：</span><a href=\"[^\"]*\">([^<]*)"];
    
    return strResult;
    
}

-(NSArray*)getBookList:(NSString*)strSource
{
    return [strSource matchedStringsWithPattern:@"ShowIdtoItem\\(.*?\\)"];
}

-(BCTBookModel*)getBookModel7788:(NSString*)strSource
                      webContent:(NSString*)strWebContent
{
    BCTBookModel *book = [BCTBookModel new];
    book.bookLink = [self getBookLink7788:strSource];
    book.title = [self getBookTitle7788:strSource];
    book.memo = [self getBookMemo7788:strSource];
    book.imgSrc = [self getBookImgStr7788:strWebContent bookTitle:book.title];
    book.author = [self getBookAuthor7788:strSource];
    book.subCategoryName = [self getBookCateogryName7788:strSource];
    
    return book;
}

-(NSString*)BuildLink:(NSString*)BID
            chapterId:(NSString*)CID
{
    //    NSString *strResult = [NSString stringWithFormat:@"{t8(u}{9h$2}www.{80gj(*F}{952J@fs}.com/xiaoshuo/%@/c/%@.html",BID,CID];
    
    NSString *strResult = [NSString stringWithFormat:@"{t8(u}{9h$2}www.{80gj(*F}{952J@fs}.com/xiaoshuo/%@/clist.html",BID];
    
    
    
    return strResult;
}


-(NSString*)re348str:(NSString*)iStr
{
    iStr = [iStr stringByReplacingOccurrencesOfString:@"{t8(u}" withString:@"htt"];
    iStr = [iStr stringByReplacingOccurrencesOfString:@"{9h$2}" withString:@"p://"];
    iStr = [iStr stringByReplacingOccurrencesOfString:@"{80gj(*F}" withString:@"dua"];
    iStr = [iStr stringByReplacingOccurrencesOfString:@"{952J@fs}" withString:@"ntian"];
    
    
    return iStr;
}


#pragma mark-  getBookChapterList

-(void)getBookChapterList:(BMBaseParam*)baseParam
{
//    NSString *strUrl = [NSString stringWithFormat:baseParam.paramString ,(long)baseParam.paramInt];
    NSString *strUrl = baseParam.paramString;
    
    strUrl = [strUrl stringByReplacingOccurrencesOfString:self.sessionManager.baseURLString withString:@""];
    
    [self.sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
        baseParam.resultArray = [self getChapterList:responseStr];
        
        
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
{
    
    NSMutableArray *aryChapterList = [NSMutableArray new];
    
    NSString *pattern = @"<dd>[\\s\\S]*?</dd>";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:strSource options:0 range:NSMakeRange(0, strSource.length)];
    for (NSTextCheckingResult *match in results) {
        
        BCTBookChapterModel *bookchaptermodel = [BCTBookChapterModel new];
        NSString* substringForMatch = [strSource substringWithRange:match.range];
//        NSLog(@"chapter list: %@",substringForMatch);
        
        NSArray *resultAry = [BCTBookAnalyzer firstMatchedStringsFromSoure:substringForMatch pattern:@"<a href=\"([^\"]*)\">([\\s\\S]*?)</a>"];
        
        bookchaptermodel.url = resultAry.firstObject;
        bookchaptermodel.title = resultAry.lastObject;
        
        bookchaptermodel.hostUrl = self.sessionManager.baseURLString;
        [aryChapterList addObject:bookchaptermodel];
    }

    return aryChapterList;
}

@end
