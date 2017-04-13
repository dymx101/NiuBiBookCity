//
//  BookCategoryModel.m
//  BookCity
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BCTBookCategoryModel.h"

//UIColor *UIColorFromNSString(NSString *string);

@implementation BCTBookCategoryModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _curIndex = 1;
        _name = data[@"categoryname"];
        _strUrl = data[@"url"];
        _categoryDescription = data[@"description"];
        _bgColor = [self UIColorFromNSString:data[@"bgColor"]];
        
        _aryUrl = data[@"urlAry"];
    }
    
    return self;
}

- (UIColor *) UIColorFromNSString:(NSString *)string {
    NSString *componentsString = [[string stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray *components = [componentsString componentsSeparatedByString:@","];
    return [UIColor colorWithRed:[(NSString*)components[0] floatValue] / 255
                           green:[(NSString*)components[1] floatValue] / 255
                            blue:[(NSString*)components[2] floatValue] / 255
                           alpha:[(NSString*)components[3] floatValue]];
}

@end
