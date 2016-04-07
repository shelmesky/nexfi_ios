//
//  UserManager.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
@interface UserManager : NSObject<NSCoding>

@property (nonatomic,assign) BOOL isLogin;

///登录成功
- (void)loginSuccessWithUser:(UserModel *)user;
///注销
- (void)logout;
///读取帐号信息
- (UserModel *)getUser;

///单例
+ (instancetype)shareManager;

@end
