//
//  NexfiNavigationController.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NexfiNavigationController.h"

@interface NexfiNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NexfiNavigationController
+ (void)initialize
{
    //bar的颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithWhite:0.1 alpha:1]];
    //设置item的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    //设置状态栏字体白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    
    //控制器title的颜色
    NSMutableDictionary *vcTitleAttr = [NSMutableDictionary dictionary];
    vcTitleAttr[NSForegroundColorAttributeName] = [UIColor whiteColor];
    vcTitleAttr[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    [[UINavigationBar appearance] setTitleTextAttributes:vcTitleAttr];
}
///根据navigation的当前显示控制器判断是否可以响应右划返回手势,避免第一个控制器pop导致页面卡住
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (navigationController.viewControllers.count > 1) {
            navigationController.interactivePopGestureRecognizer.enabled = YES;
            navigationController.interactivePopGestureRecognizer.delegate = nil;
        } else {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.delegate = self;

}
//push的时候判断到子控制器的数量。当大于零时隐藏BottomBar 也就是UITabBarController 的tababar
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(self.viewControllers.count>0){
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
