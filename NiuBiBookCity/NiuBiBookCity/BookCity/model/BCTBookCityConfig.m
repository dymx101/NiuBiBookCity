//
//  BookCityConfig.m
//  BookCity
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BCTBookCityConfig.h"
#import "BCTBookCategoryModel.h"

@implementation BCTBookCityConfig
DEF_SINGLETON(BCTBookCityConfig)

-(id)init
{
    self=[super init];
    if (self) {
        [self loadData];
    }
    return self;
}

-(void)loadData {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"bookCityConfig" ofType:@"plist"];
    NSDictionary *configDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *bookCategoriesData = configDictionary[@"BookCategory"];

    NSMutableArray *bookCategories = [NSMutableArray new];
    [bookCategoriesData enumerateObjectsUsingBlock:^(id  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        BCTBookCategoryModel *bookcategorymodel = [[BCTBookCategoryModel alloc] initWithData:item];
        [bookCategories addObject:bookcategorymodel];
    }];
    
    _bookCategories = bookCategories;
}

@end
