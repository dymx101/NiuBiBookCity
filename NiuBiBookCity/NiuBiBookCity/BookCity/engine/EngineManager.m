//
//  SearchEngineManage.m
//  BookCity
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "EngineManager.h"
#import "XiaoShuo7788Engine.h"
#import "DuanTianEngine.h"
#import "SiKushuEngine.h"
#import "H23wxEngine.h"
#import "BCTBookAnalyzer.h"
#import <AFNetworking/AFNetworking.h>
//#import <ReactiveCocoa/ReactiveCocoa.h>
#import "BlnovelEngine.h"
#import "FS99libEngine.h"
#import "Txt99Engine.h"

@interface EngineManager()
@property (nonatomic, readonly) NSDictionary *dicEnginePatterns;
@property (nonatomic, readonly) NSDictionary *dicEngines;
@property (nonatomic, readonly) NSDictionary *dicReachableManagers;

@property (nonatomic, readonly) NSMutableDictionary *dicReachableEngines;
@end


@implementation EngineManager
@dynamic sessionManager;

DEF_SINGLETON(EngineManager)

-(id)init {
    self=[super init];
    
    if (self) {
        [self loadData];
    }
    return self;
}

-(void)loadData {
    
    _dicReachableEngines = [NSMutableDictionary dictionary];
    
    // Add all engines by default
    [self addAllEngines];
    
    // remove or add engines by reachability
    [self dicReachableManagers];
}

- (NSDictionary *)dicEngines {
    static NSDictionary *dicEngines = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dicEngines = @{
//                          @(kBCTBookEngine7788).stringValue: [XiaoShuo7788Engine new]
//                              , @(kBCTBookEngineDuantian).stringValue: [DuanTianEngine new]
                          @(kBCTBookEngineSiKuShuCom).stringValue: [SiKushuEngine new]
                          , @(kBCTBookEngineSiKuShuNet).stringValue: [SiKushuEngine new]
                          , @(kBCTBookEngineH23Wx).stringValue: [H23wxEngine new]
                          , @(kBCTBookEngineBlnovel).stringValue: [BlnovelEngine new]
                          , @(kBCTBookEngineTxt99).stringValue: [Txt99Engine new]
                          };
        
    });
    
    return dicEngines;
}

- (NSDictionary *)dicEnginePatterns {
    static NSDictionary *dicEnginePatterns = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dicEnginePatterns = @{
//                              @(kBCTBookEngine7788).stringValue: @"^http://www.7788xs.cc/"
//                              , @(kBCTBookEngineDuantian).stringValue: @"^http://www.duantian.com/"
                              @(kBCTBookEngineSiKuShuCom).stringValue: @"^http://www.sikushu.com/"
                              , @(kBCTBookEngineSiKuShuNet).stringValue: @"^http://www.sikushu.net/"
                              , @(kBCTBookEngineH23Wx).stringValue: @"^http://www.23wx.cc/"
                              , @(kBCTBookEngineBlnovel).stringValue: @"^http://www.blnovel.com/"
                              , @(kBCTBookEngineTxt99).stringValue: @"^http://www.txt99.cc/"
                              };
    });
    
    return dicEnginePatterns;
}

- (NSDictionary *)dicReachableManagers {
    static NSMutableDictionary *dicReachableManagers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dicReachableManagers = [NSMutableDictionary dictionary];
        
        __weak EngineManager* weakSelf = self;
        [self.dicEngines.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            
            __strong EngineManager* strongSelf = weakSelf;
            AFNetworkReachabilityManager *reachableManager = [strongSelf addEngineIfReachableWithType:[key integerValue]];
            if (reachableManager) {
                [dicReachableManagers setObject:reachableManager forKey:key];
            }
        }];
    });
    
    return dicReachableManagers;
}

- (void)addAllEngines {
    __weak EngineManager* weakSelf = self;
    [self.dicEngines.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong EngineManager* strongSelf = weakSelf;
        id<BCIBookEngine> engine = [strongSelf.dicEngines objectForKey:key];
        [strongSelf.dicReachableEngines setObject:engine forKey:key];
    }];
}

- (AFNetworkReachabilityManager *)addEngineIfReachableWithType:(BCTBookEngineType)type {
    NSString *enginePattern = [self.dicEnginePatterns objectForKey:@(type).stringValue];
    NSString *domain = [BCTBookAnalyzer firstMatchGroupInSoure:enginePattern pattern:@"http:\\/\\/([^\\/]+)\\/"];
    
    AFNetworkReachabilityManager *reachMgr = [AFNetworkReachabilityManager managerForDomain:domain];
    [reachMgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        id<BCIBookEngine> engine = [self.dicEngines objectForKey:@(type).stringValue];
        
        if ([engine conformsToProtocol:@protocol(BCIBookEngine)]) {
            if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                [self.dicReachableEngines setObject:engine forKey:@(type).stringValue];
            } else {
                [self.dicReachableEngines removeObjectForKey:@(type).stringValue];
            }
        }
    }];
    
    [reachMgr startMonitoring];
    
    return reachMgr;
}

//

-(void)getSearchBookResult:(BMBaseParam*)baseParam {
    for (NSString *strKey in [self.dicReachableEngines allKeys]) {
        [self.dicReachableEngines[strKey] getSearchBookResult:baseParam];
        [baseParam increasePendingCallbacks];
        usleep(10);
    }
    
}

- (void)getCategoryBooksResult:(BMBaseParam*)baseParam {
    
    for (NSString *strUrl in baseParam.paramArray) {
        
        baseParam.paramString = strUrl;
        
        if ([self executeSelector:_cmd param:baseParam]) {
            [baseParam increasePendingCallbacks];
        }
        
        usleep(10);
    }
}

- (void)getBookChapterList:(BMBaseParam*)baseParam {
    [self executeSelector:_cmd param:baseParam];
}

- (void)getBookChapterDetail:(BMBaseParam*)baseParam {
    [self executeSelector:_cmd param:baseParam];
}

- (void)downloadplist:(BMBaseParam*)baseParam {
    [self executeSelector:_cmd param:baseParam];
}

- (BOOL)executeSelector:(SEL)selector param:(BMBaseParam *)param {
    __block BOOL executed = NO;
    [self.dicEnginePatterns enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {

        if ([BCTBookAnalyzer firstMatchInSoure:param.paramString pattern:obj].length > 0) {
            id<BCIBookEngine> engine = self.dicReachableEngines[key];
            if ([engine respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [engine performSelector:selector withObject:param];
#pragma clang diagnostic pop
                executed = YES;
            }
        }
    }];
    
    return executed;
}


@end
