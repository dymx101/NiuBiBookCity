//
//  BCTBookEngine.m
//  BookCity
//
//  Created by Dong Yiming on 16/4/23.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BCTBookEngine.h"
#import <AFNetworking/AFNetworking.h>
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "AFHTTPSessionManager.h"
#import "BCTSessionManager.h"
#import "BMFramework.h"
//#import "DYMBookDownloadManager.h"
#import "BCTBookAnalyzer.h"

@implementation BCTBookEngine

- (BCTSessionManager *)sessionManager {
    return nil;
}

-(void)downloadplist:(BMBaseParam*)baseParam {
    BCTBookModel *bookmodel = (BCTBookModel*)baseParam.paramObject;
    
    if (bookmodel == nil || bookmodel.aryChapterList.count == 0 ) {
        
        if (baseParam.withresultobjectblock) {
            baseParam.withresultobjectblock(-1,@"数据没有准备好，不要下载",nil);
        }
        
    }
    
    // Start downloading book
    bookmodel.finishChapterNumber = 0;
    [self downloadChapterOnePage:baseParam book:bookmodel];
}

-(void)downloadChapterOnePage:(BMBaseParam*)baseParam
                         book:(BCTBookModel*)bookmodel {
    NSInteger pageSize = 10;
    NSInteger curPageEnd = bookmodel.finishChapterNumber + pageSize;
    BCTSessionManager *sessionManager = self.sessionManager;
    
    __weak id<BCIBookEngine> weakSelf = self;
    NSInteger i = bookmodel.finishChapterNumber;
    while (i < curPageEnd && i < [bookmodel.aryChapterList count]) {
        
        if (![self.downloadManager isDownloading]) {
            break;
        }
        
        BCTBookChapterModel* bookchaptermodel = [bookmodel.aryChapterList objectAtIndex:i];
        i++;
//        usleep(100);
        
        // Get chapter url
        NSString *strUrl = bookchaptermodel.url;
        strUrl = [strUrl stringByReplacingOccurrencesOfString:sessionManager.baseURLString withString:@""];
        
        // completion block
        void (^completionBlock)(BMBaseParam *baseParam, BCTBookModel *bookmodel) = ^void(BMBaseParam *baseParam, BCTBookModel *bookmodel) {
            
            bookmodel.finishChapterNumber++;
            
            if (baseParam.withresultobjectblock) {
                if (bookmodel.finishChapterNumber == [bookmodel.aryChapterList count]) {
                    
                    [bookmodel savePlistAndImage];
                    
                    baseParam.withresultobjectblock(0, @"finished", nil);
                    
                } else {
                    
                    if(bookmodel.finishChapterNumber == curPageEnd) {
                        [weakSelf downloadChapterOnePage:baseParam book:bookmodel];
                    }
                    
                    baseParam.withresultobjectblock(0, @"downloading", nil);
                }
            }
        };
        
        // Start downloading
        id task = [sessionManager GET:strUrl parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
            
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:0x80000632];
            
            //modify by fx
            if(responseStr.length==0)
            {
                responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            
            bookchaptermodel.htmlContent = [weakSelf getChapterContent:responseStr];
            bookchaptermodel.content = [bookchaptermodel.htmlContent trimHtmlContent];
            
            completionBlock(baseParam, bookmodel);
            
        } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
            
            NSLog(@"%@",[error userInfo]);
            
            completionBlock(baseParam, bookmodel);
        }];
        
        [self.downloadManager registerDownloadingTask:task];
    }
}

//替换非utf8字符
//注意：如果是三字节utf-8，第二字节错误，则先替换第一字节内容(认为此字节误码为三字节utf8的头)，然后判断剩下的两个字节是否非法；
- (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'A','A','A','A','A','A'};                      //utf8最多6个字符，当前方法未使用
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
    
    return md;
}

@end
