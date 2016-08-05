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

@interface AppDelegate ()


@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL background;
@property (assign, nonatomic) BOOL jobExpired;


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
    [self clearVoiceCache];
    
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
    
    /*
    //后台可播放音乐
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance]setActive: YES error: &activationErr];
    */
    
    /*
    //保持后台~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"isPlayFinish"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    UIApplication* app = [UIApplication sharedApplication];
    typeof(self) __weak weakSelf = self;
    self.expirationHandler = ^{  //创建后台自唤醒，当180s时间结束的时候系统会调用这里面的方法
        [app endBackgroundTask:weakSelf.bgTask];
        weakSelf.bgTask = UIBackgroundTaskInvalid;
        weakSelf.bgTask = [app beginBackgroundTaskWithExpirationHandler:weakSelf.expirationHandler];
        NSLog(@"Expired");
        weakSelf.jobExpired = YES;
        while(weakSelf.jobExpired)
        {
            // spin while we wait for the task to actually end.
            NSLog(@"等待180s循环进程的结束");
            [NSThread sleepForTimeInterval:1];
        }
        // Restart the background task so we can run forever.
        [weakSelf startBackgroundTask];
    };
    self.bgTask = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:self.expirationHandler];
    
    NSLog(@"Entered background");
    //开启后台进程循环
    [self monitorBatteryStateInBackground];
    //保持后台~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     */
    
    
    return YES;
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
- (void)startBackgroundTask{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
        // set a flag that the job expired and use that to exit the while loop and end the task.
        NSInteger count=0;
        
        while(self.background && !self.jobExpired)
        {
            NSLog(@"进入后台进程循环");
            [NSThread sleepForTimeInterval:1];
            count++;
            if(count>30)//每60s进行一次开启定位，刷新后台时间，//60秒后播一次语音如何
            {
                NSLog(@"播一次语音~~~");
                NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
                NSString * flagStr = [def objectForKey:@"isPlayFinish"];
                NSLog(@"flagStr---%@",flagStr);
                if (![flagStr isEqualToString:@"1"])//后台没有播放
                {
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"isPlayFinish"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [[FNAVAudioPlayer sharePlayer]playBackgroudSound];
                }
                
                count=0;
            }

            NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
            NSLog(@"Background Time Remaining = %.02f Seconds",backgroundTimeRemaining);
            
        }
        self.jobExpired = NO;
    });
}

- (void)monitorBatteryStateInBackground
{
    NSLog(@"这里是干嘛");
    self.background = YES;
    [self startBackgroundTask];
}
//是否设备自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}
/*
- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}
- (NSString *)machineModelName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch",
                              @"Watch1,2" : @"Apple Watch",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}
*/
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
    __block UIBackgroundTaskIdentifier background_task;
    
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    */
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });

    
    
    /*
    self.bgTask = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:self.expirationHandler];
    
    NSLog(@"Entered background");
    //开启后台进程循环
    [self monitorBatteryStateInBackground];
    */
    
    
    /*
    //后台运行
    __block UIBackgroundTaskIdentifier background_task;
    
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(TRUE)
        {
            [NSThread sleepForTimeInterval:1];
            
            //编写执行任务代码
            NSLog(@"1");
            
        }
        
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    });
    
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     
//    self.background = NO;
//    [application endBackgroundTask:self.bgTask];
//    self.bgTask = UIBackgroundTaskInvalid;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
