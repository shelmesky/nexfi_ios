//
//  UDJackLogger.h
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Underdark.h"
#import "DDLog.h"

@protocol UDJackLoggerDelegate <NSObject>

- (void)logMessage:(NSString *)message;

@end

@interface UDJackLogger : NSObject<UDLogger>



@property (nonatomic, weak)id<UDJackLoggerDelegate>delegate;

@end

