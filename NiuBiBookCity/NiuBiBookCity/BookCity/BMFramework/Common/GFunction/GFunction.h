//
//  GFunction.h
//  DYMReader
//
//  Created by apple on 6/3/16.
//  Copyright © 2016 Dong Yiming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDefine.h"
@interface GFunction : NSObject

/*!
 *  BMContext单例
 */
#define SharedGFunction  ([GFunction sharedInstance])


-(NSMutableDictionary*)addSensitiveWordToDic:(NSArray*) ary;
-(int)CheckSensitiveWord:(NSString*) txt
                   Begin:(int)beginIndex
           SensitiveWord:(NSMutableDictionary*)sensitiveWordDic;

@end
