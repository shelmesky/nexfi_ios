//
//  AppDelegate.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SqlManager.h"
#import "NeighbourVC.h"
#import "NFAllUserChatInfoVC.h"
#import "NFSingleChatInfoVC.h"
#import "FNAVAudioPlayer.h"
//#import <SMS_SDK/SMSSDK.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

#import <CoreLocation/CoreLocation.h>

#import "BackGroundTask.h"
#import "BackGroundLocation.h"

@interface AppDelegate ()

//后台定位用

@property (strong , nonatomic) BackGroundTask *task;
@property (strong , nonatomic) NSTimer *bgTimer;
@property (strong , nonatomic) BackGroundLocation *bgLocation;
@property (strong , nonatomic) CLLocationManager *location;



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"home===%@",NSHomeDirectory());
    //创建数据库
    if ([[UserManager shareManager]getUser].userId) {
        [[SqlManager shareInstance]creatTable];
    }
    
    //初始化应用，appKey和appSecret从后台申请得
//    [SMSSDK registerApp:@"14cf8332203fa"
//             withSecret:@"3749334724b29bdbad573fa76c514ef8"];
    
    //清除语音缓存
//    [self clearVoiceCache];
    
    //高德
    [AMapServices sharedServices].apiKey = @"56e2afd4d54a42ecba325a0b738f1fac";

    
    [IQKeyboardManager sharedManager].enable = NO;
//    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10.0;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].shouldToolbarUsesTextFieldTintColor = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
//    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[NFAllUserChatInfoVC class]];

    
//    UIDevice *myDevice = [UIDevice currentDevice];
//    NSString *deviceUDID = [[myDevice identifierForVendor] UUIDString];
    
    
    _task = [BackGroundTask shareBGTask];
    UIAlertView *alert;
    //判断定位权限
    if([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusDenied)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"应用没有不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusRestricted)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不可以定位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        self.bgLocation = [[BackGroundLocation alloc]init];
        [self.bgLocation startLocation];
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(log) userInfo:nil repeats:YES];
    }
    
    return YES;
    
}
-(void)log
{
    NSLog(@"执行");
}
-(void)startBgTask
{
    [_task beginNewBackgroundTask];
}
- (void)clearVoiceCache{
    
    NSError *fileError;
    //清除部分语音缓存
    NSString *amrPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audio/amr"];
    NSArray *amrFilePathArr = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:amrPath error:&fileError];
    for (NSString *str in amrFilePathArr) {
        if ([[NSFileManager defaultManager]removeItemAtPath:[amrPath stringByAppendingPathComponent:str] error:nil]) {
            NSLog(@"删除%@成功",str);
        }
    }
    
    NSString *wavPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audio/wav"];
    NSArray *wavFilePathArr = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:wavPath error:nil];
    for (NSString *str in wavFilePathArr) {
        if ([[NSFileManager defaultManager]removeItemAtPath:[wavPath stringByAppendingPathComponent:str] error:nil]) {
            NSLog(@"删除%@成功",str);
        }
    }
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
//是否设备自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 }

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
