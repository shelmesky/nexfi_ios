//
//  UserManager.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager
static UserManager *_userManager;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userManager = [[UserManager alloc]init];
    });
    return _userManager;
}
//用户是否登陆
- (BOOL)isLogin{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
}
//用户登陆成功存储信息
- (void)loginSuccessWithUser:(UserModel *)user{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *acountPath = [self getPathWithFileName:@"account.data"];
    NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [accountData writeToFile:acountPath atomically:YES];
}
//用户退出登陆
- (void)logout{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *acountPath = [self getPathWithFileName:@"account.data"];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:acountPath error:&error];
    if (error) {
        NSLog(@"delete error : %@",error);
    }
}
//获取用户信息
- (UserModel *)getUser{
    NSString *acountPath = [self getPathWithFileName:@"account.data"];
    NSData *accountData = [[NSData alloc] initWithContentsOfFile:acountPath];
    UserModel *user = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
    return user;
}
//用户信息路径
- (NSString *)getPathWithFileName:(NSString *)fileName{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}
@end
