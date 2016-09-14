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
#import "NexfiUtil.h"
#import "BackGroundTask.h"
#import "BackGroundLocation.h"

#import "UnderdarkUtil.h"

#import "DocumentLoadVC.h"
#import "NexfiNavigationController.h"
#import "FileModel.h"

@interface AppDelegate ()

//后台定位用

@property (strong , nonatomic) BackGroundTask *task;
@property (strong , nonatomic) NSTimer *bgTimer;
@property (strong , nonatomic) BackGroundLocation *bgLocation;


@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign)BOOL isNeedUpdate;

@property (nonatomic, retain)NSMutableArray *locationList;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"home===%@",NSHomeDirectory());
    //创建数据库
    if ([[UserManager shareManager]getUser].userId) {
        [[SqlManager shareInstance]creatTable];
    }
    self.locationList = [[NSMutableArray alloc]initWithCapacity:0];
    
    

    
    //初始化应用，appKey和appSecret从后台申请得
//    [SMSSDK registerApp:@"14cf8332203fa"
//             withSecret:@"3749334724b29bdbad573fa76c514ef8"];
    
    //清除语音缓存
//    [self clearVoiceCache];
    //18502569914
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
    
    //更新位置
//    [self updateLocation];
    
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
    
    self.location = [[CLLocationManager alloc] init];
    self.location.delegate = self;
    self.location.pausesLocationUpdatesAutomatically = NO;
    [self.location startUpdatingLocation];
    self.isNeedUpdate = YES;
    
    // 跳转三方；
    if (launchOptions) {
        NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
        //返回的url， 转换成nsstring;
        NSString *appfilePath =[[[url description] componentsSeparatedByString:@"file:///private"] lastObject];
        appfilePath = [appfilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //        DocListViewController *doc = [[DocListViewController alloc] init];
        //        doc.appFilePath = appfilePath;
        //        [_nav pushViewController:doc animated:YES];
    }
    
    return YES;
    
}
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    if (options) {
        //        NSString *str = [NSString stringWithFormat:@"\n发送请求的应用程序的 Bundle ID：%@\n\n文件的NSURL：%@", options[UIApplicationOpenURLOptionsSourceApplicationKey], url];
        // 返回的url， 例如这样；
        //    	@"file:///private/var/mobile/Containers/Data/Application/A2E0485F-1341-48A3-BD40-6D09CB8559F5/Documents/Inbox/2-6.pptx"
        // 返回的url， 转换成nsstring;
        NSString *appfilePath = [[[url description] componentsSeparatedByString:@"file:///private"] lastObject];
        //        appfilePath = [appfilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        appfilePath =  [appfilePath stringByRemovingPercentEncoding];
        NSLog(@"appfilePath:%@", appfilePath);
        //获取当前页面的nav
        NexfiNavigationController *nav = self.tabbar.viewControllers[self.tabbar.selectedIndex];
        DocumentLoadVC *destinVc = [[DocumentLoadVC alloc]init];
        
        //CC460527-FFE7-459E-8B02-504890D00588/Documents/nexfi_BDD3E379-C24D-4D1D-AC37-63E4F3DE2468.db
        NSString *partPath = [[appfilePath componentsSeparatedByString:@"/Application/"] lastObject];
   
        NSArray *a = [partPath componentsSeparatedByString:@"/"];
        
        NSMutableString *finallyPartPath = [[NSMutableString alloc]initWithCapacity:0];
        for (int i = 0; i < a.count; i ++) {
            NSString *ss = a[i];
            if (i != 0) {
                [finallyPartPath appendString:ss];
                if (i != a.count - 1) {
                    [finallyPartPath appendString:@"/"];
                }
            }
        }
        
        //finallyPartPath  Documents/nexfi_BDD3E379-C24D-4D1D-AC37-63E4F3DE2468.db
        
        //配置参数
        FileModel *model = [[FileModel alloc] init];
        model.fileName  = [[appfilePath componentsSeparatedByString:@"/"] lastObject];
        model.fileAbsolutePath = appfilePath;
        model.partPath = finallyPartPath;
        
        
        //归档 NSKeyedArchiver
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        /*
        //历史文件列表
        if (files.count == 0) {
            NSMutableArray *addFiles = [[NSMutableArray alloc]initWithCapacity:0];
            [addFiles addObject:data];
            NSArray *saveFiles = [NSArray arrayWithArray:addFiles];
            [[NSUserDefaults standardUserDefaults]setObject:saveFiles forKey:@"historyFiles"];
        }else{
            NSArray *historyFiles = [[NSUserDefaults standardUserDefaults]objectForKey:@"historyFiles"];
            NSMutableArray *addFiles = [[NSMutableArray alloc]initWithArray:historyFiles];
            [addFiles addObject:data];
            NSArray *saveFiles = [NSArray arrayWithArray:addFiles];
            [[NSUserDefaults standardUserDefaults]setObject:saveFiles forKey:@"historyFiles"];
        }
        destinVc.currentFileModel = model;
        destinVc.title = model.fileName;
        
        [nav pushViewController:destinVc animated:YES];
        */
        
        //{@"文档":[文档1的data，文档1的data]}
        NSDictionary *fileDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"historyFiles"];
        
        NSMutableDictionary *currentFileDic = fileDic?[[NSMutableDictionary alloc]initWithDictionary:fileDic]:[[NSMutableDictionary alloc]initWithCapacity:0];
        BOOL isExecutive = NO;
        //判断是否有重复文件
        for (NSArray *arr in currentFileDic.allValues) {
            for (NSData *data in arr) {
                
                FileModel *file = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                //获取本地存储的路径 并进行拼接  Documents Library 目录下的都要做判断
                NSString *documentPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *fileSuffix = [[file.fileAbsolutePath componentsSeparatedByString:@"/Documents/"] lastObject];
                NSString *libraryPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
                NSString *fileSuffixL = [[file.fileAbsolutePath componentsSeparatedByString:@"/Library/"] lastObject];
                //文件路径
                NSString *documentSubPath = [documentPath stringByAppendingPathComponent:fileSuffix];
                NSString *LibrarySubPath = [libraryPath stringByAppendingPathComponent:fileSuffixL];
                //如果已经存在此文件不需要存储 直接去查看
                if ([[NSFileManager defaultManager]contentsEqualAtPath:documentSubPath andPath:model.fileAbsolutePath] || [[NSFileManager defaultManager]contentsEqualAtPath:LibrarySubPath andPath:model.fileAbsolutePath]) {
                    //移除本地文件
                    [[NSFileManager defaultManager]removeItemAtPath:model.fileAbsolutePath error:nil];
                    
                    destinVc.currentFileModel = file;
                    destinVc.title = file.fileName;
                    
                    isExecutive = YES;
                    
                    [nav pushViewController:destinVc animated:YES];

                }
            }
        }

        //没有重复文件继续执行
        if (!isExecutive) {
            //分割文件路径 doc
            NSString *pathExtation = [[model.fileName componentsSeparatedByString:@"."] lastObject];
            //归类 比如文档 音频 视频
            NSString *fileSuffix = [NexfiUtil getFileTypeWithFileSuffix:pathExtation];
            NSMutableArray *currentFileArr = currentFileDic[fileSuffix];
            if (!currentFileArr) {
                currentFileArr = [[NSMutableArray alloc]initWithCapacity:0];
                [currentFileArr addObject:data];
                currentFileDic[fileSuffix] = currentFileArr;
            }else{
                NSMutableArray *finallyFileArr = [[NSMutableArray alloc]initWithArray:currentFileArr];
                [finallyFileArr addObject:data];
                currentFileDic[fileSuffix] = finallyFileArr;
            }
            //{@"文档":[文档1的data，文档1的data]}
            NSDictionary *finallyFileDic = [NSDictionary dictionaryWithDictionary:currentFileDic];
            
            [[NSUserDefaults standardUserDefaults]setObject:finallyFileDic forKey:@"historyFiles"];
            
            destinVc.currentFileModel = model;
            destinVc.title = model.fileName;
            
            [nav pushViewController:destinVc animated:YES];
        }
        
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
#pragma -mark 创建定时器 10分钟发送一次位置
- (void)updateLocation{
    __block int count = 0;
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(180.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        count ++ ;
        NSLog(@"1111");
        if (count == 0) {
            // 取消定时器
            dispatch_cancel(self.timer);
            //                self.timer = nil;
        }
        self.isNeedUpdate = YES;
        //        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error//当定位服务不可用出错时，系统会自动调用该函数
{
    NSLog(@"定位服务出错");
    if([error code]==kCLErrorDenied)//通过error的code来判断错误类型
    {
        //Access denied by user
        NSLog(@"定位服务未打开");
        //        [InterfaceFuncation ShowAlertWithMessage:@"错误" AlertMessage:@"未开启定位服务\n客户端保持后台功能需要调用系统的位置服务\n请到设置中打开位置服务" ButtonTitle:@"好"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations//当用户位置改变时，系统会自动调用，这里必须写一点儿代码，否则后台时间刷新不管用
{
//    NSLog(@"位置改变，必须做点儿事情才能刷新后台时间");
    CLLocation *loc = [locations lastObject];
    //NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    //NSLog(@"Background Time Remaining = %.02f Seconds",backgroundTimeRemaining);
    // Lat/Lon
    float latitudeMe = loc.coordinate.latitude;
    float longitudeMe = loc.coordinate.longitude;
    NSLog(@"la====%f====lo====%f",latitudeMe,longitudeMe);
    
    //10分钟发送一次定位位置
    if (self.isNeedUpdate) {
        self.isNeedUpdate = NO;
        //更新用户信息
        UserModel *user = [[UserManager shareManager]getUser];
        /*
        user.lattitude = [NSString stringWithFormat:@"%f",loc.coordinate.latitude];
        user.longitude = [NSString stringWithFormat:@"%f",loc.coordinate.longitude];
        [[UserManager shareManager]loginSuccessWithUser:user];
         */
        
        NSArray *arr = @[
                         @{@"lattitude":@"31.203223",@"longitude":@"121.52322"},
                         @{@"lattitude":@"31.212333",@"longitude":@"121.52562"},
                         @{@"lattitude":@"31.212513",@"longitude":@"121.42932"},
                         @{@"lattitude":@"31.208633",@"longitude":@"121.52142"},
                         @{@"lattitude":@"31.207632",@"longitude":@"121.52141"},
                         @{@"lattitude":@"31.218630",@"longitude":@"121.52139"},
                         @{@"lattitude":@"31.219628",@"longitude":@"121.52137"},
                         @{@"lattitude":@"31.203626",@"longitude":@"121.52135"},
                         @{@"lattitude":@"31.205624",@"longitude":@"121.52133"},
                         @{@"lattitude":@"31.206622",@"longitude":@"121.52131"}];
        
        
        
        
//        NSDictionary *d = arr[arc4random_uniform(0)];
        NSDictionary *d = arr[9];
        
        user.lattitude = d[@"lattitude"];
        
        user.longitude = d[@"longitude"];
        [[UserManager shareManager]loginSuccessWithUser:user];
        
        if ([UnderdarkUtil share].node.links.count > 0) {
            for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
                id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
                [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UserLocationUpdate WithLink:myLink]];
            }
        }
    }
}
@end
