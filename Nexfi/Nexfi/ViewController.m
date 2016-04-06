//
//  ViewController.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ViewController.h"
#import "ChatVC.h"
#import "ChatInfoVC.h"
#import "UserManager.h"
#import "SelfVC.h"
#import "NeighbourVC.h"
#import "NexfiNavigationController.h"
@interface ViewController ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.window = [UIApplication sharedApplication].windows[0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    /*
     判断是否自动登录
     */
    [self isAutoLogin];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame =CGRectMake(100, 100, 50, 50);
    [b setTitle:@"跳去聊天" forState:UIControlStateNormal];
    b.backgroundColor = [UIColor blueColor];
    [b addTarget:self action:@selector(pushToChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
}
- (void)isAutoLogin{
    NSString *userId = [[UserManager shareManager]getUser].userId;
    if (userId) {//登录直接获取数据
        [self layOutTheApp];
    }else{
        [self loginAction];
    }
}
- (void)loginAction{
    
}
#pragma mark -布局tabbar
- (void)layOutTheApp
{
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    //设定Tabbar的点击后的颜色 #ffa055
    [[UITabBar appearance] setTintColor:RGBACOLOR(248, 64, 28, 1)];
    // [[UITabBar appearance] setBackgroundColor:[UIColor colorWithHexString:@"#373737"]];
    [[UITabBar appearance] setBackgroundImage:[ConFunc createImageWithColor:RGBACOLOR(251, 251, 251, 1)
                                                                       size:CGSizeMake(SCREEN_SIZE.width,SCREEN_SIZE.height)]];//设置背景，修改颜色是没有用的
    
    //设定Tabbar的颜色
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    NexfiNavigationController *neighbouVC = [self newNavigationControllerForClass:[NeighbourVC class]
                                                                    title:@"附近"
                                                                itemImage:@"fujin01"
                                                            selectedImage:@"fujin02"];
    NexfiNavigationController *selfVC = [self newNavigationControllerForClass:[SelfVC class]
                                                                     title:@"我的"
                                                                 itemImage:@"wode01"
                                                             selectedImage:@"wode02"];

    
    tabbar.viewControllers = @[neighbouVC,selfVC];
    self.window.rootViewController = tabbar;
}
- (NexfiNavigationController *)newNavigationControllerForClass:(Class)controllerClass
                                                        title:(NSString *)title
                                                    itemImage:(NSString *)itemImage
                                                selectedImage:(NSString *)selectedImage
{
    UIViewController *viewController = [[controllerClass alloc] init];
    NexfiNavigationController *theNavigationController = [[NexfiNavigationController alloc]
                                                         initWithRootViewController:viewController];
    theNavigationController.tabBarItem.title = title;
    theNavigationController.tabBarItem.image = [UIImage imageNamed:itemImage];
    theNavigationController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    theNavigationController.navigationBarHidden = YES;
    return theNavigationController;
}

- (void)pushToChat:(id)sender{
    ChatInfoVC *vc = [[ChatInfoVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
