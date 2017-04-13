//
//  BCTSessionManager.h
//  BookCity
//
//  Created by Dong Yiming on 16/4/23.
//  Copyright © 2016年 FS. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "BCIBookEngine.h"

@interface BCTSessionManager : AFHTTPSessionManager

@property (nonatomic, readonly) NSString *baseURLString;

+ (instancetype)sessionManagerWithEngineType:(BCTBookEngineType)engineType;

@end
