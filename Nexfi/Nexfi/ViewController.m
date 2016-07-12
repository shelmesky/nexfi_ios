//
//  ViewController.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ViewController.h"
#import "NFSingleChatInfoVC.h"
#import "UserManager.h"
#import "SelfVC.h"
#import "NeighbourVC.h"
#import "NexfiNavigationController.h"
#import "UserInfoVC.h"
#import "RegisterVC.h"
@interface ViewController ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //网络检测通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    //网络监测
    Reachability *reach =[Reachability reachabilityWithHostname:@"www.apple.com"];

    [reach startNotifier];
    
    UserModel *user = [[UserManager shareManager]getUser];
    if (!user) {
        UserModel *user = [[UserModel alloc]init];
        [[UserManager shareManager]loginSuccessWithUser:user];
    }


}
- (void)reachabilityChanged: (NSNotification *)notification{
    Reachability *reach = [notification object];
    
    if (reach.isReachable) {
        /*
         判断是否自动登录
         */
        [self isAutoLoginWithwifi];
    }else{
        /*
         判断是否自动登录
         */
        [self isAutoLoginWithNoWifi];
    }
}
- (void)isAutoLoginWithwifi{
    NSString *userId = [[UserManager shareManager]getUser].userId;
    NSString *phoneNum = [[UserManager shareManager]getUser].phoneNumber;
    if (userId && phoneNum) {//登录直接获取数据
        [[NexfiUtil shareUtil] layOutTheApp];
    }else if (phoneNum){//只注册手机号 没有用户信息
        UserInfoVC *vc = [[UserInfoVC alloc]init];
        NexfiNavigationController *nav = [[NexfiNavigationController alloc]initWithRootViewController:vc];
        UIWindow *window = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
        window.rootViewController = nav;
    }else{
        RegisterVC *vc = [[RegisterVC alloc]init];
        NexfiNavigationController *nav = [[NexfiNavigationController alloc]initWithRootViewController:vc];
        UIWindow *window = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
        window.rootViewController = nav;
    }
}
- (void)isAutoLoginWithNoWifi{
    NSString *userId = [[UserManager shareManager]getUser].userId;
    if (userId) {//登录直接获取数据
        [[NexfiUtil shareUtil] layOutTheApp];
    }else{
        UserInfoVC *vc = [[UserInfoVC alloc]init];
        NexfiNavigationController *nav = [[NexfiNavigationController alloc]initWithRootViewController:vc];
        UIWindow *window = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
        window.rootViewController = nav;
    }
}
- (void)pushToChat:(id)sender{
    NFSingleChatInfoVC *vc = [[NFSingleChatInfoVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
