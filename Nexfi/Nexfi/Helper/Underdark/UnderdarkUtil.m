//
//  UnderdarkUtil.m
//  Nexify
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UnderdarkUtil.h"

@implementation UnderdarkUtil

static UnderdarkUtil *_underdatk;

+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _underdatk = [[UnderdarkUtil alloc]init];
    });
    return _underdatk;
}
- (id)init{
    if (self = [super init]) {
        _udlogger = [[UDJackLogger alloc]init];
        [UDUnderdark setLogger:_udlogger];

        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        _node = [[Node alloc] init];
    }
    return self;
}
@end
