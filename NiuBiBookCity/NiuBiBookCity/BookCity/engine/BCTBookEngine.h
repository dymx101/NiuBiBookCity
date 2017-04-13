//
//  BCTBookEngine.h
//  BookCity
//
//  Created by Dong Yiming on 16/4/23.
//  Copyright © 2016年 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCIBookEngine.h"
#import "BCTSessionManager.h"

@protocol BTCBookDownloadManagerInterface <NSObject>

- (BOOL)isDownloading;
- (void)registerDownloadingTask:(NSURLSessionDataTask *)task;

@end

@interface BCTBookEngine : NSObject <BCIBookEngine>
@property (weak, nonatomic) id<BTCBookDownloadManagerInterface> downloadManager;
@end
