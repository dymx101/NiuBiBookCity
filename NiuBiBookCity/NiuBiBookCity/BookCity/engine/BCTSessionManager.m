//
//  BCTSessionManager.m
//  BookCity
//
//  Created by Dong Yiming on 16/4/23.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BCTSessionManager.h"

@implementation BCTSessionManager

- (NSString *)baseURLString {
    return self.baseURL.absoluteString;
}

+ (NSDictionary *)baseURLs {
    static NSDictionary *baseURLs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseURLs = @{
                     @(kBCTBookEngine7788): @"http://www.7788xs.cc/"
                     , @(kBCTBookEngineDuantian): @"http://www.duantian.com/"
                     , @(kBCTBookEngineSiKuShuCom): @"http://www.sikushu.com/"
                     , @(kBCTBookEngineSiKuShuNet): @"http://www.sikushu.net/"
                     , @(kBCTBookEngineH23Wx): @"http://www.23wx.com/"
                     , @(kBCTBookEngineBlnovel): @"http://www.blnovel.com/"
                     , @(kBCTBookEngineTxt99): @"http://www.txt99.cc/"
                     , @(kBCTBookEngineFS99lib): @"http://www.99lib.net/"
                     , @(kBCTBookEngineZhanneiBaidu): @"http://zhannei.baidu.com/"};
    });
    
    return baseURLs;
}

+ (instancetype)sessionManagerWithEngineType:(BCTBookEngineType)engineType {
    static NSMutableDictionary *sessionManagers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManagers = [NSMutableDictionary dictionary];
    });
    
    if (sessionManagers[@(engineType)] == nil) {
        BCTSessionManager *manager = [self _constructSessionManagerWithEngineType:engineType];
        sessionManagers[@(engineType)] = manager;
    }
    
    return sessionManagers[@(engineType)];
}

+ (BOOL)_isGBEncodingWithEngineType:(BCTBookEngineType)engineType {
    return engineType == kBCTBookEngineSiKuShuCom
    || engineType == kBCTBookEngineSiKuShuNet
    || engineType == kBCTBookEngineBlnovel
    || engineType == kBCTBookEngineTxt99
    || engineType == kBCTBookEngineFS99lib
    || engineType == kBCTBookEngineZhanneiBaidu;
}

+ (BOOL)_needToRequestAsBrowserWithEngineType:(BCTBookEngineType)engineType {
    return engineType == kBCTBookEngineZhanneiBaidu;
}


+ (instancetype)_constructSessionManagerWithEngineType:(BCTBookEngineType)engineType {
    NSString *baseURL = [self baseURLs][@(engineType)];
    NSURLSessionConfiguration *config = [self sessionConfiguration];
    BCTSessionManager *manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL] sessionConfiguration:config];
    
    // Response Settings
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    
    // Request Settings
    if ([self _isGBEncodingWithEngineType:engineType]) {
        manager.requestSerializer.stringEncoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    }
    
    if ([self _needToRequestAsBrowserWithEngineType:engineType]) {
        [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4" forHTTPHeaderField:@"User-Agent"];
    }
    
    return manager;
}

+ (NSURLSessionConfiguration *)sessionConfiguration {
    static NSURLSessionConfiguration *sessionConfiguration = nil;
    if (sessionConfiguration == nil) {
        [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.dymReader.backgroundDownloadSession"];
    }
    
    return sessionConfiguration;
}

@end
