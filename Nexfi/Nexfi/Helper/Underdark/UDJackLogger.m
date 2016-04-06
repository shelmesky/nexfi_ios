//
//  UDJackLogger.m
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UDJackLogger.h"

@implementation UDJackLogger

- (void)log:(BOOL)asynchronous level:(UDLogLevel)level flag:(UDLogFlag)flag context:(NSInteger)context file:(const char *)file function:(const char *)function line:(NSUInteger)line tag:(id)tag message:(NSString *)message{
    [DDLog log:asynchronous message:message level:(DDLogLevel)level flag:(DDLogFlag)flag context:context file:file function:function line:line tag:tag];
    NSString *nmessage = message;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(log:message:)]) {
            [self.delegate logMessage:nmessage];
        }
    });

}



@end
