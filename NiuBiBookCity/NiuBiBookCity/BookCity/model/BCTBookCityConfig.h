//
//  BookCityConfig.h
//  BookCity
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDefine.h"

@interface BCTBookCityConfig : NSObject
AS_SINGLETON(BCTBookCityConfig)


//@property (nonatomic,strong) NSDictionary *dicConfig;
@property (nonatomic,strong) NSArray *bookCategories;

@end
