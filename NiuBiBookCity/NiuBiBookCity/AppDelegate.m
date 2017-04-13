//
//  AppDelegate.m
//  NiuBiBookCity
//
//  Created by Dong, Yiming (Agoda) on 4/13/17.
//  Copyright © 2017 Dong, Yiming (Agoda). All rights reserved.
//

#import "AppDelegate.h"
#import "BMFramework.h"
#import "BCTBookModel.h"
#import "DefineHeader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self testSearch];
    
    return YES;
}


- (void)testSearch {
    //实例化一个传入传出参数
    BMBaseParam* baseparam = [BMBaseParam new];
    
    //参数
    baseparam.paramString = @"盗墓";
    baseparam.paramInt = 0;
    
    __weak BMBaseParam *weakBaseParam = baseparam;
    baseparam.withresultobjectblock = ^(int intError,NSString* strMsg,id obj) {
        
        [weakBaseParam reducePendingCallbacks];
        
        if (intError == 0) {
            
            NSArray *books = weakBaseParam.resultArray;
            
            if (books.count > 0) {
                NSArray *sortedBooks = [books sortedArrayUsingComparator:^NSComparisonResult(BCTBookModel * _Nonnull obj1, BCTBookModel * _Nonnull obj2) {
                    
                    NSInteger quality1 = [obj1 quality];
                    NSInteger quality2 = [obj2 quality];
                    
                    if (quality1 > quality2) {
                        return NSOrderedAscending;
                    } else if (quality1 < quality2) {
                        return NSOrderedDescending;
                    }
                    
                    return NSOrderedSame;
                }];
                
                NSLog(@"%@", sortedBooks);
                
            }
        }
    };
    
    NSMutableDictionary* dicParam = [NSMutableDictionary createParamDic];
    [dicParam setActionID:DEF_ACTIONID_BOOKACTION strcmd:DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT];
    [dicParam setParam:baseparam];
    
    [SharedControl excute:dicParam];
}


@end
