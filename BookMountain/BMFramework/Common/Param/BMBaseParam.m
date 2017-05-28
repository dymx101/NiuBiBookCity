//
//  XSBaseParam.m
//  Babylon
//
//  Created by fx on 14-3-1.
//  Copyright (c) 2014年 Yixue. All rights reserved.
//

#import "BMBaseParam.h"

@interface BMBaseParam ()
@property (nonatomic, assign) NSInteger pendingBlockCount;
@end


@implementation BMBaseParam


/*!
 This is a comment about FunctionName1.
 */
-(id)init
{
    self=[super init];
    if (self) {
        [self initData];
    }
    return self;
}
/*!
 This is a comment about FunctionName.
 */
-(void)initData
{
    self.paramArray=[NSMutableArray new];
    self.paramDic = [NSMutableDictionary new];
}


- (void)increasePendingCallbacks {
    _pendingBlockCount++;
//    NSLog(@"increse: %@", @(_pendingBlockCount));
}

- (void)reducePendingCallbacks {
    _pendingBlockCount--;
//    NSLog(@"reduce: %@", @(_pendingBlockCount));
}

- (BOOL)hasMoreCallBacks {
    return _pendingBlockCount > 0;
}


@end
