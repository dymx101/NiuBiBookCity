//
//  NiuBiBookCityTests.m
//  NiuBiBookCityTests
//
//  Created by Dong, Yiming (Agoda) on 4/13/17.
//  Copyright © 2017 Dong, Yiming (Agoda). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Txt99Engine.h"
#import "BMFramework.h"
#import "DefineHeader.h"
#import "BCTBookModel.h"
#import "BCTBookChapterModel.h"

static const CGFloat unitTestTimeout = 10;
static const BOOL unitTestEnableLogging = true;

@interface Tx99EnginTests : XCTestCase
@property (nonatomic, strong) Txt99Engine *engine;
@end

@implementation Tx99EnginTests

- (void)setUp {
    self.engine = [Txt99Engine new];
    
    [super setUp];
}

- (void)tearDown {
    
    self.engine = nil;
    
    [super tearDown];
}

- (void)testSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSearch"];
    
    BMBaseParam* baseparam = [BMBaseParam new];
    baseparam.paramString = @"盗墓";
    baseparam.paramInt = 0;
    
    __weak BMBaseParam *weakBaseParam = baseparam;
    baseparam.withresultobjectblock = ^(int intError, NSString* strMsg, id obj) {
        
        if (intError == 0) {
            
            if (unitTestEnableLogging) {
                NSArray *books = weakBaseParam.resultArray;
                if ([books.firstObject isKindOfClass:[BCTBookModel class]]) {
                    NSString *link = ((BCTBookModel *)books.firstObject).bookLink;
                    NSLog(@"Book Link: %@", link);
                }
            }
            
            [expectation fulfill];
            
        }
    };
    
    [self.engine getSearchBookResult:baseparam];
    
    [self waitForExpectationsWithTimeout:unitTestTimeout handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}

- (void)testGetChapterList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetChapterList"];
    
    BMBaseParam* baseparam = [BMBaseParam new];
    baseparam.paramString = @"http://www.txt99.cc/readbook/17068.html";
    
    __weak BMBaseParam *weakBaseParam = baseparam;
    
    baseparam.withresultobjectblock=^(int intError,NSString* strMsg,id obj) {
        
        if (intError == 0) {
            
            if (unitTestEnableLogging) {
                NSArray *chapters = weakBaseParam.resultArray;
                if ([chapters.firstObject isKindOfClass:[BCTBookChapterModel class]]) {
                    BCTBookChapterModel *chapter = ((BCTBookChapterModel *)chapters.firstObject);
                    NSLog(@"**Chapter** ->\n HostURL: %@ \nURL: %@", chapter.hostUrl, chapter.url);
                }
            }
            
            [expectation fulfill];
        }
        
    };
    
    [self.engine getBookChapterList:baseparam];
    
    [self waitForExpectationsWithTimeout:unitTestTimeout handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}

//HostURL:, URL:
- (void)testGetBookChapterDetail {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetChapterList"];
    
    BMBaseParam* baseparam=[BMBaseParam new];
    
    //参数
    baseparam.paramString = @"http://www.txt99.cc/";
    baseparam.paramString2 = @"http://www.txt99.cc/readbook/17068_1.html";
    
    __weak BMBaseParam *weakBaseParam = baseparam;
    baseparam.withresultobjectblock=^(int intError,NSString* strMsg,id obj) {
        if (intError == 0) {
            
            if (unitTestEnableLogging) {
                NSLog(@"Chapter Content: %@", weakBaseParam.resultString);
            }
            
            [expectation fulfill];
        }
    };
    
    [self.engine getBookChapterDetail:baseparam];
    
    [self waitForExpectationsWithTimeout:unitTestTimeout handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}

@end
