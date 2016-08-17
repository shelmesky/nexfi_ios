//
//  BackGroundLocation.m
//  Nexfi
//
//  Created by fyc on 16/8/9.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BackGroundLocation.h"
#import "BackGroundTask.h"
#import "UnderdarkUtil.h"
@interface BackGroundLocation()
{
    BOOL isCollect;
    BOOL isNeedUpdate;
}
@property (strong , nonatomic) dispatch_source_t timer; //后台任务
@property (strong , nonatomic) BackGroundTask *bgTask; //后台任务
@property (strong , nonatomic) NSTimer *restarTimer; //重新开启后台任务定时器
@property (strong , nonatomic) NSTimer *closeCollectLocationTimer; //关闭定位定时器 （减少耗电）

@end
@implementation BackGroundLocation

//初始化
-(instancetype)init
{
    if(self == [super init])
    {
        //
        _bgTask = [BackGroundTask shareBGTask];
        isCollect = NO;
        //监听进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
//        //刚进入页面也要调用
//        CLLocationManager *locationManager = [BackGroundLocation shareBGLocation];
//        locationManager.delegate = self;
//        locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
//        if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
//            [locationManager requestAlwaysAuthorization];
//        }
//        [locationManager startUpdatingLocation];
//        
//        [self updateLocation];
        

    }
    return self;
}
+(CLLocationManager *)shareBGLocation
{
    static CLLocationManager *_locationManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    });
    return _locationManager;
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
    uint64_t interval = (uint64_t)(10.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        count ++ ;
        
        if (count == 0) {
            // 取消定时器
            dispatch_cancel(self.timer);
            //                self.timer = nil;
        }
        isNeedUpdate = YES;
        //        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}
//后台监听方法
-(void)applicationEnterBackground
{
    NSLog(@"come in background");
    CLLocationManager *locationManager = [BackGroundLocation shareBGLocation];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    [_bgTask beginNewBackgroundTask];
}
//重启定位服务
-(void)restartLocation
{
    NSLog(@"重新启动定位");
    CLLocationManager *locationManager = [BackGroundLocation shareBGLocation];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    [self.bgTask beginNewBackgroundTask];
}
//开启服务
- (void)startLocation {
    NSLog(@"开启定位");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [BackGroundLocation shareBGLocation];
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
    }
}

//停止后台定位
-(void)stopLocation
{
    NSLog(@"停止定位");
    isCollect = NO;
    CLLocationManager *locationManager = [BackGroundLocation shareBGLocation];
    [locationManager stopUpdatingLocation];
}
#pragma mark --delegate
//定位回调里执行重启定位和关闭定位
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"定位收集");
    //如果正在10秒定时收集的时间，不需要执行延时开启和关闭定位
    if (isCollect) {
        return;
    }
    [self performSelector:@selector(restartLocation) withObject:nil afterDelay:120];
    [self performSelector:@selector(stopLocation) withObject:nil afterDelay:10];
    isCollect = YES;//标记正在定位
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启后台服务" message:@"应用没有不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}
// 定位成功，获取定位到的经纬度
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"location has got -------> latitude: %f , longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    //10分钟发送一次定位位置
    if (isNeedUpdate) {
        NSLog(@"11");
        isNeedUpdate = NO;
        //更新用户信息
        UserModel *user = [[UserManager shareManager]getUser];
        user.lattitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        user.longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
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
