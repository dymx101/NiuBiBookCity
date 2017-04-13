//
//  NSString+Trim.m
//  DYMReader
//
//  Created by Dong, Yiming (Agoda) on 9/3/2559 BE.
//  Copyright © 2559 Dong Yiming. All rights reserved.
//

#import "NSString+BookCity.h"

@implementation NSString (BookCity)


#pragma mark - Trim
- (NSString *)trimWithExcludedStrings:(NSArray *)excludedStrings {
    
    return [self replaceSubStrings:excludedStrings withStrings:@[@""]];
}

- (NSString *)trimWithRegExString:(NSString *)regExString {
    return [self replaceWithString:@"" regExString:regExString];
}

- (NSString *)trimHtmlContent {

    NSString *strContent = [self trimWithExcludedStrings:@[@"<p>", @"<br>"]];
    strContent = [strContent replaceSubStrings:@[@"&nbsp;&nbsp;"] withStrings:@[@" "]];
    
    strContent = [strContent replaceWithString:@"\r\n" regExString:@"<br />[\\s]*?<br />"];
    strContent = [strContent replaceWithString:@"\r\n" regExString:@"<br/>[\\s]*?<br/>"];
    
    NSString *result = [strContent replaceSubStrings:@[@"</p>", @"<br/>", @"<br />", @"\r\n\r\n"] withStrings:@[@"\r\n"]] ? : @"";
    
    return result;
}

#pragma mark - Replace
- (NSString *)replaceWithString:(NSString *)replaceString regExString:(NSString *)regExString {
    return [self stringByReplacingOccurrencesOfString:regExString
                                           withString:replaceString ? : @""
                                              options:NSRegularExpressionSearch
                                                range:NSMakeRange(0, self.length)];
}

- (NSString *)replaceSubStrings:(NSArray *)targetStrings withStrings:(NSArray *)replaceStrings {
    
    __block NSString *resultString = self;
    [targetStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull excludedString, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *replaceStr = (idx < replaceStrings.count) ? replaceStrings[idx] : replaceStrings.lastObject;
        
        resultString = [resultString stringByReplacingOccurrencesOfString:excludedString withString:(replaceStr ? : @"")];
    }];
    
    return resultString;
}

#pragma mark - RegEx
- (NSArray *)matchesWithPattern:(NSString *)pattern {
    
    if (pattern.length <= 0) {
        return nil;
    }
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    
    return [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}

- (NSArray *)matchedStringsWithPattern:(NSString *)pattern {
    NSArray *matches = [self matchesWithPattern:pattern];
    if (matches.count > 0) {
        NSMutableArray *matchedStrings = [NSMutableArray arrayWithCapacity:matches.count];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult  * _Nonnull match, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString* substringForMatch = [self substringWithRange:match.range];
            if (substringForMatch) {
                [matchedStrings addObject:substringForMatch];
            }
        }];
        
        return matchedStrings;
    }
    
    return nil;
}

@end
