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
            
            NSArray *books = weakBaseParam.resultArray;
            NSLog(@"%@", books.firstObject);
            [expectation fulfill];
            
        }
    };
    
    [self.engine getSearchBookResult:baseparam];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}


@end
