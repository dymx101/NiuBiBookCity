//
//  BCIBookEngine.h
//  BookCity
//
//  Created by Dong Yiming on 16/4/21.
//  Copyright © 2016年 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMBaseParam;
@class BCTSessionManager;
@class BCTBookModel;


typedef NS_ENUM(NSInteger, BCTBookEngineType) {
    kBCTBookEngine7788 = 100
    , kBCTBookEngineDuantian
    , kBCTBookEngineSiKuShuCom
    , kBCTBookEngineSiKuShuNet
    , kBCTBookEngineH23Wx
    , kBCTBookEngineBlnovel
    , kBCTBookEngineTxt99
    , kBCTBookEngineFS99lib
    , kBCTBookEngineZhanneiBaidu
};


@protocol BCIBookEngine <NSObject>

@property (nonatomic, readonly) BCTSessionManager *sessionManager;

@optional

- (NSString*)getChapterContent:(NSString*)strSource;

- (void)getSearchBookResult:(BMBaseParam*)baseParam;

- (void)getCategoryBooksResult:(BMBaseParam*)baseParam;

- (void)getBookChapterList:(BMBaseParam*)baseParam;

- (void)getBookChapterDetail:(BMBaseParam*)baseParam;

- (void)downloadplist:(BMBaseParam*)baseParam;

- (void)downloadChapterOnePage:(BMBaseParam*)baseParam
                         book:(BCTBookModel*)bookmodel;

- (NSData *)replaceNoUtf8:(NSData *)data;

@end
