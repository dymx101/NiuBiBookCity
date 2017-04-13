//
//  BookModel.m
//  AFNetworking Example
//
//  Created by apple on 15/12/29.
//
//

#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"
#import "BCTBookCategoryModel.h"
#import "BMUtilDefine.h"

#import <SDWebImage/UIImageView+WebCache.h>
//#import "DYMBookModel.h"
//#import <MagicalRecord/MagicalRecord.h>
//#import "DYMBookDownloadManager.h"
#import "NSString+BookCity.h"

static NSString *downloadPath = nil;

@implementation BCTBookModel

-(NSMutableDictionary*)toDic
{
    NSMutableDictionary *retDic = [NSMutableDictionary new];
    [retDic setObject:self.author forKey:@"author"];
    [retDic setObject:@"no_cover.png" forKey:@"cover"];
    [retDic setObject:@"" forKey:@"isbn"];
    [retDic setObject:@"-999" forKey:@"order"];
    [retDic setObject:@"default.png" forKey:@"src"];
    [retDic setObject:@"已完成" forKey:@"status"];
    [retDic setObject:self.title forKey:@"title"];
    
    
    NSMutableArray *aryPartTitle = [NSMutableArray new];
    [aryPartTitle addObject:@"章节列表"];
    [retDic setObject:aryPartTitle forKey:@"partTitleArr"];
    
    NSMutableArray *aryChapter= [NSMutableArray new];
    NSMutableArray *aryChapter2= [NSMutableArray new];
    
    for (NSInteger i = 0; i < [self.aryChapterList count]; i++) {
        BCTBookChapterModel *bookchaptermodel = [self.aryChapterList objectAtIndex:i];
        
        NSMutableDictionary *chapterDic = [NSMutableDictionary new];
        
        [chapterDic setObject:bookchaptermodel.content forKey:@"chapterContent"];
        [chapterDic setObject:@"" forKey:@"chapterSrcs"];
        [chapterDic setObject:bookchaptermodel.title forKey:@"chapterTitle"];
        [chapterDic setObject:@"" forKey:@"href"];
        
        [aryChapter2 addObject:chapterDic];
    }
    [aryChapter addObject:aryChapter2];
    
    [retDic setObject:aryChapter forKey:@"chapterArrArr"];
    
    return retDic;
}

+ (NSString *)downloadPath {
    if (downloadPath == nil) {
        downloadPath = [NSString stringWithFormat:@"%@/download_books", DocumentsDir];
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return downloadPath;
}

-(BOOL)savePlistAndImage {
    
    [self saveImgSrc];
    
    NSString *plistFile = [NSString stringWithFormat:@"%@/%@.plist", [BCTBookModel downloadPath], self.title];
    
    NSMutableDictionary *bookDic = [self toDic];
    
    [[NSFileManager defaultManager] removeItemAtPath:plistFile error:nil];
    
    BOOL isSuccess = [bookDic writeToFile:plistFile atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"book_resource_saved" object:self];
    
    return isSuccess;
}

-(void)saveImgSrc
{
    if (self.imgSrc == nil || self.imgSrc.length == 0) {
        return;
    }
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.imgSrc] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    }
        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
    {
        if (image&&finished) {
            NSData *imagedata = UIImageJPEGRepresentation(image,1.0);
            
//            NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            
//            NSString *documentsDirectory=[paths objectAtIndex:0];
            
            NSString *downloadPath = [BCTBookModel downloadPath];
            NSString *imgPath = [NSString stringWithFormat:@"%@/%@.jpeg", downloadPath, self.title];
            
            [imagedata writeToFile:imgPath atomically:YES];
        }
    }];
}

-(void)setMemo:(NSString *)memo {
    _memo = [memo trimWithExcludedStrings:@[@" ", @"　"]];
}

-(NSInteger)quality {
    NSInteger quality = 0;
    if (self.imgSrc.length > 0) {
        quality += 5;
    }
    
    if (self.memo.length > 0) {
        quality += 2;
    }
    
    return quality;
}


@end
