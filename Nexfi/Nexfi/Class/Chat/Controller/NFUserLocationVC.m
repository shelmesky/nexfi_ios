//
//  NFUserLocationVC.m
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "NFUserLocationVC.h"
#import "CustomAnnotationView.h"
#import "NFSingleChatInfoVC.h"
#import "VertifyCodeVC.h"
#import "NeighbourVC.h"
#import "MapTypeView.h"

#define kCalloutViewMargin          -8


@interface NFUserLocationVC ()<CustomAnnotationDelegate,MapTypeViewPro,
BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    BOOL _isShow;
}
@property (nonatomic, retain)NSMutableArray *annotations;
@property (nonatomic, retain)NSMutableArray * runningCoords;
@property (nonatomic, assign)int count;
@property (nonatomic, retain)NSMutableArray *indexes;
@property (nonatomic, retain)NSMutableArray *speedColors;
@property (nonatomic, retain)NSMutableArray *polyLines;
@property (nonatomic, retain)NSMutableArray *headOverLines;
@property (nonatomic, retain)NSMutableArray *simulateHeatNodes;
@property (nonatomic, strong) MapTypeView *mapTypeView;
@property (nonatomic, strong)BMKLocationService* locService;//定位服务
@property (nonatomic, strong)BMKHeatMap *heatMap; //热力图数据类

@end

@implementation NFUserLocationVC
- (NSMutableArray *)simulateHeatNodes{
    if (!_simulateHeatNodes) {
        _simulateHeatNodes = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _simulateHeatNodes;
}
- (NSMutableArray *)headOverLines{
    if (!_headOverLines) {
        _headOverLines = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _headOverLines;
}
- (NSMutableArray *)polyLines{
    if (!_polyLines) {
        _polyLines = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _polyLines;
}
- (NSMutableArray *)runningCoords{
    if (!_runningCoords) {
        _runningCoords = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _runningCoords;
}
- (NSMutableArray *)speedColors{
    if (!_speedColors) {
        _speedColors  =[[NSMutableArray alloc]initWithCapacity:0];
    }
    return _speedColors;
}
- (NSMutableArray *)indexes{
    if (!_indexes) {
        _indexes = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _indexes;
}
- (NSMutableArray *)annotations{
    if (!_annotations) {
        _annotations = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _annotations;
}
-(void)viewWillAppear:(BOOL)animated {
    [_bdMapView viewWillAppear];
    _bdMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    //非根视图默认添加返回按钮
    if ([self.navigationController.viewControllers count] > 0
        && self != [self.navigationController.viewControllers objectAtIndex:0])
    {
        [self setLeftButtonWithImageName:@"title-icon-向左返回" bgImageName:nil];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated {
    
    [USER_D setObject:@"NO" forKey:@"showHeatOverlay"];
    [USER_D setObject:@"NO" forKey:@"showTraffic"];
    [USER_D synchronize];
    
    [_bdMapView viewWillDisappear];
    _bdMapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    [USER_D setObject:@"NO" forKey:@"showHeatOverlay"];
    [USER_D setObject:@"NO" forKey:@"showTraffic"];
    
    [self initMapView];
    
    [self configureData];
    
    [self configureTrifficAndMap];

    [self setBaseVCAttributesWith:@"附近的人" left:nil right:nil WithInVC:self];
    
    UIBarButtonItem *show = [[UIBarButtonItem alloc]initWithTitle:@"我的轨迹"
                                                        style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(showLine:)];
    self.navigationItem.rightBarButtonItem = show;
    
    _isShow = NO;
    if (self.friendList.count > 0) {
        [self showMyFriendLocation];
    }
     
    
    
    
    //3分钟更新下用户位置
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFriendInfo)
//name:@"updateFriendInfo" object:nil];
    
}
- (void)updateFriendInfo{
    [self showMyFriendLocation];
}
- (void)configureData{
    NSString *locationsPath = [[NSBundle mainBundle]pathForResource:@"locations" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:locationsPath];
    
    if (data) {
        _simulateHeatNodes = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        
    }
}
#pragma mark -初始化数据
- (void)configureTrifficAndMap{
    NSString *trafficStr =[USER_D objectForKey:@"showTraffic"];
    if ([trafficStr isEqualToString:@"YES"]) {
        self.bdMapView.trafficEnabled = YES;
        UIButton *trafficBtn = (UIButton *)[self.view viewWithTag:1001];
        [trafficBtn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
    }else{
        self.bdMapView.trafficEnabled = NO;
    }
    
    NSString *typeStr = [USER_D objectForKey:@"MAMapType"];
    if ([typeStr isEqualToString:@"卫星图"]) {
        self.bdMapView.mapType = BMKMapTypeSatellite;
    }else{
        self.bdMapView.mapType = BMKMapTypeStandard;
    }
    
    NSString *headOverlay = [USER_D objectForKey:@"showHeatOverlay"];
    if ([headOverlay isEqualToString:@"YES"]) {
        UIButton *heatOverlayBtn = (UIButton *)[self.view viewWithTag:1003];
        [heatOverlayBtn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
//        [self.bdMapView setBaiduHeatMapEnabled:YES];
        [self addHeatOverlay];
    }else{
//        [self.bdMapView setBaiduHeatMapEnabled:NO];
        [self showMyFriendLocation];
    }
    
    NSString *locationStr = [USER_D objectForKey:@"showUserLocation"];
    if ([locationStr isEqualToString:@"YES"]) {
        self.bdMapView.showsUserLocation = YES;
    }else{
        self.bdMapView.showsUserLocation = NO;
    }
    
    [self.view bringSubviewToFront:self.trafficBtn];
    [self.view bringSubviewToFront:self.mapTypeBtn];
    [self.view bringSubviewToFront:self.mapOverLayBtn];
    [self.view bringSubviewToFront:self.locationBtn];
}
#pragma mark -画线轨迹
- (void)showMyPolyLine{
    
    //移除标注
    [self.bdMapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    //隐藏热力图
//    [self.bdMapView setBaiduHeatMapEnabled:NO];
    [self.bdMapView removeHeatMap];

    //刷新用户数据
    [self refreshUserData];
    
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc
    (self.runningCoords.count * sizeof(CLLocationCoordinate2D));
    
    
    for (int i = 0; i < self.runningCoords.count; i ++) {
    CLLocation *location = self.runningCoords[i];
    coordinateArray[i] = location.coordinate;
    }
    
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coordinateArray
                                                           count:self.runningCoords.count];
    [self.polyLines addObject:polyline];
    [self.bdMapView addOverlay:polyline];
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake
    (screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.bdMapView setVisibleMapRect:polyline.boundingMapRect edgePadding:inset animated:NO];

}
#pragma mark -刷新用户数据
- (void)refreshUserData{
    for (UIViewController *v in self.navigationController.viewControllers) {
        if ([v isKindOfClass:[NeighbourVC class]]) {
            NeighbourVC *neighbourVc = (NeighbourVC *)v;
            self.friendList = [[NSMutableArray alloc]initWithArray:neighbourVc.handleByUsers];
        }
    }
}
#pragma mark -展示所有用户位置
- (void)showMyFriendLocation{
    
    [self.bdMapView removeOverlays:self.polyLines];
    [self.bdMapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    //移除热力图
//    [self.bdMapView setBaiduHeatMapEnabled:NO];
    [self.bdMapView removeHeatMap];
    
    //刷新用户数据
    [self refreshUserData];
    
    //在地图上添加标注
    [self addAnnotation];
    
}
#pragma mark -是否显示热力图
- (void)showHeadMapOverLay:(UIButton *)btn{
    NSString *str =[USER_D objectForKey:@"showHeatOverlay"];
    NSString *trafficString;
    
    //刷新用户数据
    [self refreshUserData];
    
    if ([str isEqualToString:@"YES"]) {
        trafficString = @"NO";
//        [self.bdMapView setBaiduHeatMapEnabled:NO];
        [self showMyFriendLocation];
        [btn setBackgroundImage:[UIImage imageNamed:@"fence_close"] forState:0];
    }else{
//        [self.bdMapView setBaiduHeatMapEnabled:YES];
        [self addHeatOverlay];
        trafficString = @"YES";
        [btn setBackgroundImage:[UIImage imageNamed:@"fence_open"] forState:0];
    }
    [USER_D setObject:trafficString forKey:@"showHeatOverlay"];
    [USER_D synchronize];
}
#pragma mark -是否显示路况
- (void)showTrafficEvent:(UIButton *)btn
{
    NSString *str =[USER_D objectForKey:@"showTraffic"];
    if (str.length>0) {
        if ([str isEqualToString:@"YES"]) {
            self.bdMapView.trafficEnabled = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
        }else{
            self.bdMapView.trafficEnabled = YES;
            [btn setBackgroundImage:[UIImage imageNamed:@"traffic_open"] forState:0];
        }
    }else {
        self.bdMapView.trafficEnabled = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"traffic_open"] forState:0];
    }
    NSString *trafficString = self.bdMapView.trafficEnabled?@"YES":@"NO";
    [USER_D setObject:trafficString forKey:@"showTraffic"];
    [USER_D synchronize];
}
#pragma mark - 是否显示用户位置
- (void)showUserLocation:(UIButton *)btn{
    NSString *userLocation = [USER_D objectForKey:@"showUserLocation"];
    if ([userLocation isEqualToString:@"YES"]) {
        UIAlertView *locationAlert = [[UIAlertView alloc]initWithTitle:@"是否隐藏您当前所在位置?"
                                                               message:nil delegate:self cancelButtonTitle:@"确定"
                                                     otherButtonTitles:@"取消", nil];
        locationAlert.tag = 10002;
        [locationAlert show];
        
    }else{
        UIAlertView *locationAlert = [[UIAlertView alloc]initWithTitle:@"是否显示您当前所在位置?"
                                                               message:nil delegate:self cancelButtonTitle:@"确定"
                                                     otherButtonTitles:@"取消", nil];
        locationAlert.tag = 10001;
        [locationAlert show];
    }
    
    
}
- (IBAction)changeMapViewStatues:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case 1001:
            
        {
            [self showTrafficEvent:button];
        }
            break;
        case 1002:
        {
            
            float width = button.frame.size.width;
            
            UIView  *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
            maskView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:maskView];
            WEAKSELF;
            [maskView whenTapped:^{
                [UIView animateWithDuration:0.2 animations:^{
                    [weakSelf.mapTypeView removeFromSuperview];
                    [maskView removeFromSuperview];
                    [_mapTypeBtn setBackgroundImage:[UIImage imageNamed:@"map_switch"] forState:0];
                }];
                
            }];

            _mapTypeView = [[MapTypeView alloc] initWithFrame:CGRectMake
                            (button.frame.origin.x+width-223, button.y + button.height, 223, 100)];
            _mapTypeView.delegate = self;
            [self.view addSubview:_mapTypeView];
            [_mapTypeBtn setBackgroundImage:[UIImage imageNamed:@"close_map_Type_tip"] forState:0];
        }
            break;
        case 1003:
            
        {
            
            NSString *str =[USER_D objectForKey:@"showHeatOverlay"];
            NSString *trafficString;
            
            
            if ([str isEqualToString:@"YES"]) {
                trafficString = @"NO";
                //        [self.bdMapView setBaiduHeatMapEnabled:NO];
                [self showMyFriendLocation];
                [button setBackgroundImage:[UIImage imageNamed:@"fence_close"] forState:0];
                
                [USER_D setObject:trafficString forKey:@"showHeatOverlay"];
                [USER_D synchronize];
                
            }else{
                UIAlertView *locationAlert = [[UIAlertView alloc]initWithTitle:@"是否显示其他用户位置?"
                                                                       message:nil delegate:self cancelButtonTitle:@"确定"
                                                             otherButtonTitles:@"取消", nil];
                locationAlert.tag = 10003;
                [locationAlert show];
            }
            
        }
            break;
        case 1004:
            
        {
            [self showUserLocation:button];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - MapTypeViewPro
- (void)changeMAMapType:(NSString *)type
{
    if ([type isEqualToString:@"卫星图"]) {
        self.bdMapView.mapType = BMKMapTypeSatellite;
    }else{
        self.bdMapView.mapType = BMKMapTypeStandard;
    }
}
- (UIColor *)getColorForSpeed:(float)speed
{
    const float lowSpeedTh = 2.f;
    const float highSpeedTh = 3.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    
    float hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
#pragma mark -配置热力图
- (void)addHeatOverlay{
    
    [self.bdMapView removeOverlays:self.polyLines];
    [self.bdMapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    
    //刷新用户数据
    [self refreshUserData];
    

    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        });
    //    });;
    
    NSMutableArray *distanceArr = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *needIntensityEqual1 = [[NSMutableArray alloc]initWithCapacity:0];
    
    UserModel *mySelf = [[UserManager shareManager]getUser];
    BMKMapPoint point1 = BMKMapPointForCoordinate
    (CLLocationCoordinate2DMake(mySelf.lattitude.floatValue,mySelf.longitude.floatValue));
    
    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
            (user.lattitude.floatValue, user.longitude.floatValue);
            
            BMKMapPoint point2 = BMKMapPointForCoordinate(coordinate);
            
            //计算两点之间的距离
            CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            NSDictionary *userDistance = @{@"distance":@(distance),@"userId":user.userId,
                                           @"lattitude":user.lattitude,@"longitude":user.longitude};
            [distanceArr addObject:userDistance];
            
        }
    }
    
    for (int i = 0; i < _simulateHeatNodes.count; i ++) {
        NSDictionary *dic = _simulateHeatNodes[i];
        NSString *userId = [NSString stringWithFormat:@"AbcDeFgH-%d",i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
        ([dic[@"lat"] floatValue], [dic[@"lng"] floatValue]);
        
        BMKMapPoint point2 = BMKMapPointForCoordinate(coordinate);
        //计算两点之间的距离
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        NSDictionary *userDistance = @{@"distance":@(distance),@"userId":userId,
                                       @"lattitude":dic[@"lat"],@"longitude":dic[@"lng"]};
        [distanceArr addObject:userDistance];
        
    }
    
    //判断两个点之间距离是否小于300 如果小于 放到needIntensityEqual1 并将它的热点intensity 设置为1 否则设置0.3
    for (int i = 0; i < distanceArr.count - 1; i ++) {
        for (int j = i + 1; j < distanceArr.count - 1; j ++) {
            NSDictionary *d1 = distanceArr[i];
            NSDictionary *d2 = distanceArr[j];
            
            if (fabsf([d1[@"distance"] floatValue] - [d2[@"distance"] floatValue]) < 300) {
                if (![needIntensityEqual1 containsObject:d1[@"userId"]]) {
                    [needIntensityEqual1 addObject:d1];
                }
                if (![needIntensityEqual1 containsObject:d2[@"userId"]]) {
                    [needIntensityEqual1 addObject:d2];
                }
            }
        }
    }
    
    for (NSDictionary *user in distanceArr) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
        ([user[@"lattitude"] floatValue], [user[@"longitude"] floatValue]);
        
        //热力图标注
        BMKHeatMapNode *node = [[BMKHeatMapNode alloc]init];
        node.pt = coordinate;
        node.intensity = 0.3;
        if ([needIntensityEqual1 containsObject:user]) {
            node.intensity = 1.0;
        }
        [self.headOverLines addObject:node];
    }
    
    self.heatMap.mData = self.headOverLines;
    [self.heatMap setMGradient:[[BMKGradient alloc]initWithColors:@[[UIColor blueColor],
                                                                    [UIColor greenColor],
                                                                    
                                                                    
                                                                    [UIColor yellowColor],
                                                                    [UIColor redColor]]
                                                      startPoints:@[@(0.2),
                                                                    @(0.4),@(0.6)
                                                                    ,@(0.8)]]];
    self.heatMap.mRadius = 40;
    self.heatMap.mOpacity = 0.3;
    
    [self.bdMapView addHeatMap:self.heatMap];
    


    
}
#pragma mark -配置标注
-(void)addAnnotation
{

    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            //标注
            BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];

            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
                        (user.lattitude.floatValue,user.longitude.floatValue);
            pointAnnotation.coordinate = coordinate;
            pointAnnotation.title = user.userNick;
            pointAnnotation.subtitle = user.userId;
            [self.annotations addObject:pointAnnotation];
            

        }
    }
    [self.bdMapView addAnnotations:self.annotations];
    [self.bdMapView showAnnotations:self.annotations animated:YES];

}
- (void)initMapView
{
    self.bdMapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.bdMapView.delegate = self;
    self.bdMapView.showsUserLocation = NO;
    self.bdMapView.userTrackingMode = BMKUserTrackingModeNone;
    self.bdMapView.buildingsEnabled = YES;//是否显示3D楼块效果
//    [self.bdMapView setBaiduHeatMapEnabled:YES];
    [self.view addSubview:self.bdMapView];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    self.heatMap = [[BMKHeatMap alloc]init];
}
- (UserModel *)getUserFromAnnotationWithUserId:(NSString *)userId{
    UserModel *getUser;
    for (UserModel *user in self.friendList) {
        if ([user.userId isEqualToString:userId]) {
            getUser = user;
        }
    }
    
    return getUser;
}
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_bdMapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_bdMapView updateLocationData:userLocation];
    
    if (userLocation.location.coordinate.latitude == 0 ||
        userLocation.location.coordinate.longitude == 0) {
        return;
    }
    CLLocation *nowLocation = [[CLLocation alloc]initWithLatitude:
                               userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    [self.runningCoords addObject:nowLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}


- (void)dealloc {
    if (_bdMapView) {
        _bdMapView = nil;
    }
}
//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.lineWidth = 5;
        polylineView.strokeColor = [UIColor blueColor];
        
        return polylineView;
    }
    return nil;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    
}
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:
(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"renameMark";
        CustomAnnotationView *annotationView = [[CustomAnnotationView alloc]initWithAnnotation:
                                                annotation reuseIdentifier:AnnotationViewID];
        
        
        //必须设置no 不然没法设置自定义弹出view
        annotationView.canShowCallout = NO;
        annotationView.customDelegate = self;
        annotationView.draggable = YES;
        UserModel *user = [self getUserFromAnnotationWithUserId:annotation.subtitle];
        annotationView.portrait = [UIImage imageNamed:user.userAvatar];
        annotationView.name     = user.userNick;
    
        
        return annotationView;
    }
    
    return nil;
}
#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10001) {//展示用户位置
        if (buttonIndex == 0) {
            self.bdMapView.showsUserLocation = YES;
            NSString *location = self.bdMapView.showsUserLocation?@"YES":@"NO";
            [USER_D setObject:location forKey:@"showUserLocation"];
            [USER_D synchronize];
        }
    }else if(alertView.tag == 10002){//隐藏用户位置
        if (buttonIndex == 0) {
            self.bdMapView.showsUserLocation = NO;
            NSString *location = self.bdMapView.showsUserLocation?@"YES":@"NO";
            [USER_D setObject:location forKey:@"showUserLocation"];
            [USER_D synchronize];
        }
    }else if (alertView.tag == 10003){//展示热力图
        if (buttonIndex == 0) {
            UIButton *button = (UIButton *)[self.view viewWithTag:1003];
            [self showHeadMapOverLay:button];
        }
    }
}
- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}
#pragma -mark CustomAnnotationViewDelegate
- (void)chatToSb:(id)sender{
    CustomAnnotationView *cusView = (CustomAnnotationView *)sender;
    //点击去私聊
    UserModel *user = [self getUserFromAnnotationWithUserId:cusView.annotation.subtitle];
    /*
    if (user.phoneNumber) {//已经注册直接去私聊
        NFSingleChatInfoVC *chat = [[NFSingleChatInfoVC alloc]init];
        chat.to_user = user;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        VertifyCodeVC *vc = [[VertifyCodeVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
     */
    
     NFSingleChatInfoVC *chat = [[NFSingleChatInfoVC alloc]init];
     chat.to_user = user;
     [self.navigationController pushViewController:chat animated:YES];

}
#pragma -mark  显示我的用户轨迹
- (void)showLine:(id)sender{
    _isShow = !_isShow;
    if (_isShow) {
        self.navigationItem.rightBarButtonItem.title = @"隐藏";
        [self showMyPolyLine];
    }else{
        self.navigationItem.rightBarButtonItem.title = @"我的轨迹";
        [self showMyFriendLocation];
    }
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
