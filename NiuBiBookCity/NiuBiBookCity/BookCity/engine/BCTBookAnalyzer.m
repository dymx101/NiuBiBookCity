//
//  BCTBookAnalyzer.m
//  BookCity
//
//  Created by apple on 16/1/4.
//  Copyright © 2016年 FS. All rights reserved.
//

#import "BCTBookAnalyzer.h"

@implementation BCTBookAnalyzer

+ (NSString*)firstMatchInSoure:(NSString*)strSource pattern:(NSString*)strPattern {
    return [self firstMatchFromSoure:strSource pattern:strPattern groupIndex:0];
}

+ (NSString*)firstMatchGroupInSoure:(NSString*)strSource pattern:(NSString*)strPattern {
    return [self firstMatchFromSoure:strSource pattern:strPattern groupIndex:1];
}

+ (NSString*)firstMatchFromSoure:(NSString*)strSource pattern:(NSString*)strPattern groupIndex:(NSUInteger)groupIndex {
    if (strSource.length > 0 && strPattern.length > 0) {
        NSArray *matchs = [strSource matchesWithPattern:strPattern];
        
        return [self _stringFromSource:strSource matches:matchs groupIndex:groupIndex];
    }
    
    return @"";
}

+ (NSArray *)firstMatchedStringsFromSoure:(NSString*)strSource pattern:(NSString*)strPattern {
    
    if (strSource.length > 0 && strPattern.length > 0) {
        NSArray *matches = [strSource matchesWithPattern:strPattern];
        
        if (matches.count > 0) {
            NSAssert([matches.firstObject isKindOfClass:[NSTextCheckingResult class]], @"Matched item should be a 'NSTextCheckingResult'");
            
            NSMutableArray *matchedStrings = [NSMutableArray array];
            NSTextCheckingResult *checkingResult = ((NSTextCheckingResult *)matches.firstObject);
            for(NSInteger i = 1; i < [checkingResult numberOfRanges]; i++) {
                NSRange range = [checkingResult rangeAtIndex:i];
                if (range.location != NSNotFound && range.location + range.length <= strSource.length) {
                    NSString *matchedString = [strSource substringWithRange:range];
                    if (matchedString) {
                        [matchedStrings addObject:matchedString];
                    }
                }
            }
            
            return matchedStrings;
        }
    }
    
    return nil;
}

#pragma mark - Internal Methods
+ (NSString *)_stringFromSource:(NSString *)source matches:(NSArray *)matches groupIndex:(NSUInteger)groupIndex {
    if (matches.count > 0) {
        NSAssert([matches.firstObject isKindOfClass:[NSTextCheckingResult class]], @"Matched item should be a 'NSTextCheckingResult'");
        
        NSRange range = [((NSTextCheckingResult *)matches.firstObject) rangeAtIndex:groupIndex];
        if (range.location != NSNotFound && range.location + range.length <= source.length) {
            return [source substringWithRange:range];
        }
    }
    
    return @"";
}

@end
