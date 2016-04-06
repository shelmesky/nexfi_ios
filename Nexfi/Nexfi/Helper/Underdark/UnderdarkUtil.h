//
//  UnderdarkUtil.h
//  Nexify
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "Node.h"
#import "UDJackLogger.h"
#import "CocoaLumberjack.h"
@interface UnderdarkUtil : NSObject

@property (nonatomic, strong)Node *node;
@property (nonatomic, strong)UDJackLogger *udlogger;
+ (instancetype)share;

@end
