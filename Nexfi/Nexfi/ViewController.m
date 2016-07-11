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
    
    
    UserModel *user = [[UserManager shareManager]getUser];
    if (!user) {
        UserModel *user = [[UserModel alloc]init];
        [[UserManager shareManager]loginSuccessWithUser:user];
    }

    /*
     判断是否自动登录
     */
    [self isAutoLogin];
    

}
- (void)isAutoLogin{
    NSString *userId = [[UserManager shareManager]getUser].userId;
//    NSString *phoneNum = [[UserManager shareManager]getUser].phoneNumber;
    if (userId ) {//登录直接获取数据
        [[NexfiUtil shareUtil] layOutTheApp];
    }else{
        [self loginAction];
    }
}
- (void)loginAction{
    RegisterVC *vc = [[RegisterVC alloc]init];
//    UserInfoVC *vc = [[UserInfoVC alloc]init];
    NexfiNavigationController *nav = [[NexfiNavigationController alloc]initWithRootViewController:vc];
//    nav.navigationBarHidden = YES;
    UIWindow *window = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    window.rootViewController = nav;
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
