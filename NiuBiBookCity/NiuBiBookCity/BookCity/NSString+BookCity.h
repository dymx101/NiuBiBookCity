//
//  NSString+BookCity
//  DYMReader
//
//  Created by Dong, Yiming (Agoda) on 9/3/2559 BE.
//  Copyright © 2559 Dong Yiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BookCity)

- (NSString *)trimWithExcludedStrings:(NSArray *)excludedStrings;
- (NSString *)trimWithRegExString:(NSString *)regExString;
- (NSString *)trimHtmlContent;

- (NSString *)replaceSubStrings:(NSArray *)targetStrings withStrings:(NSArray *)replaceStrings;
- (NSString *)replaceWithString:(NSString *)replaceString regExString:(NSString *)regExString;

#pragma mark - RegEx
- (NSArray *)matchesWithPattern:(NSString *)pattern;
- (NSArray *)matchedStringsWithPattern:(NSString *)pattern;

@end
