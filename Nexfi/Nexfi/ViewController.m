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
    
    /*
    //网络检测通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    //网络监测
    Reachability *reach =[Reachability reachabilityWithHostname:@"www.apple.com"];

    [reach startNotifier];
     */
    
    //无限播放音乐
//    [self runloopPlayMusic];
    
    
    UserModel *user = [[UserManager shareManager]getUser];
    if (!user) {
        UserModel *user = [[UserModel alloc]init];
        [[UserManager shareManager]loginSuccessWithUser:user];
    }
    
    [self isAutoLoginWithNoWifi];
    
    
    
    
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
- (void)runloopPlayMusic{    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        NSError *audioSessionError = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError]){
            NSLog(@"Successfully set the audio session.");
        } else {
            NSLog(@"Could not set the audio session");
        }
        [[AVAudioSession sharedInstance]setActive:YES error:nil];
        
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"backgroundSound" ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        
        if (audioPlayer != nil){
            audioPlayer.delegate = self;
            
            [audioPlayer setNumberOfLoops:-1];
            if ([audioPlayer prepareToPlay] && [audioPlayer play]){
                NSLog(@"Successfully started playing...");
            } else {
                NSLog(@"Failed to play.");
            }
        } else {
            
        }
    });
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
