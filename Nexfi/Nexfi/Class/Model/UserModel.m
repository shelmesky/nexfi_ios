//
//  UserModel.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)initWithaDic:(NSDictionary *)aDic{
    if (self = [super init]) {
        self.userId = aDic[@"userId"];
        self.userName = aDic[@"userName"];
        self.sex = aDic[@"sex"];
        self.userHead = aDic[@"userHead"];
    }
    return self;
}
@end
