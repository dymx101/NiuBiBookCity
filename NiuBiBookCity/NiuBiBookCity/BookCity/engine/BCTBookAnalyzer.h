//
//  BCTBookAnalyzer.h
//  BookCity
//
//  Created by apple on 16/1/4.
//  Copyright © 2016年 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMFramework.h"
#import "NSString+BookCity.h"

@interface BCTBookAnalyzer : NSObject

+ (NSString*)firstMatchInSoure:(NSString*)strSource pattern:(NSString*)strPattern;
+ (NSString*)firstMatchGroupInSoure:(NSString*)strSource pattern:(NSString*)strPattern;
+ (NSString*)firstMatchFromSoure:(NSString*)strSource pattern:(NSString*)strPattern groupIndex:(NSUInteger)groupIndex;
+ (NSArray *)firstMatchedStringsFromSoure:(NSString*)strSource pattern:(NSString*)strPattern;

@end
