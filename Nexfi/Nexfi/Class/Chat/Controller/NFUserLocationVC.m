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


@interface NFUserLocationVC ()<MAMapViewDelegate,CustomAnnotationDelegate,MapTypeViewPro>
{
    MAMultiPolyline * _polyline;
    BOOL _isShow;
}
@property (nonatomic, retain)NSMutableArray *annotations;
@property (nonatomic, assign)BOOL isNeedUpdate;;
@property (nonatomic, retain)NSMutableArray * runningCoords;
@property (nonatomic, assign)int count;
@property (nonatomic, retain)NSMutableArray *indexes;
@property (nonatomic, retain)NSMutableArray *speedColors;
@property (nonatomic, retain)NSMutableArray *polyLines;
@property (nonatomic, retain)NSMutableArray *headOverLines;
@property (nonatomic, retain)NSMutableArray *simulateHeatNodes;
@property (nonatomic, strong) MapTypeView *mapTypeView;
@property (nonatomic, strong) MAHeatMapTileOverlay *heatMapTileOverlay;
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
- (void)viewWillDisappear:(BOOL)animated{
    [USER_D setObject:@"NO" forKey:@"showHeatOverlay"];
    [USER_D setObject:@"NO" forKey:@"showTraffic"];
    [USER_D synchronize];
    
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [USER_D setObject:@"NO" forKey:@"showHeatOverlay"];
    [USER_D setObject:@"NO" forKey:@"showTraffic"];
    
    self.isNeedUpdate = YES;
        
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
        self.mapView.showTraffic = YES;
        UIButton *trafficBtn = (UIButton *)[self.view viewWithTag:1001];
        [trafficBtn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
    }else{
        self.mapView.showTraffic = NO;
    }
    
    NSString *typeStr = [USER_D objectForKey:@"MAMapType"];
    if ([typeStr isEqualToString:@"卫星图"]) {
        self.mapView.mapType = MAMapTypeSatellite;
    }else{
        self.mapView.mapType = MAMapTypeStandard;
    }
    
    NSString *headOverlay = [USER_D objectForKey:@"showHeatOverlay"];
    if ([headOverlay isEqualToString:@"YES"]) {
        [self addHeatOverlay];
        UIButton *heatOverlayBtn = (UIButton *)[self.view viewWithTag:1003];
        [heatOverlayBtn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
    }else{
        [self showMyFriendLocation];
    }
    
    [self.view bringSubviewToFront:self.trafficBtn];
    [self.view bringSubviewToFront:self.mapTypeBtn];
    [self.view bringSubviewToFront:self.mapOverLayBtn];
}
#pragma mark -画线轨迹
- (void)showMyPolyLine{
    
    //移除标注
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    //隐藏热力图
    [self.mapView removeOverlays:self.headOverLines];
    [self.headOverLines removeAllObjects];
    [self.heatMapTileOverlay setOpacity:0];
    
    MATileOverlayRenderer *render = (MATileOverlayRenderer *)[self.mapView rendererForOverlay:
                                                              self.heatMapTileOverlay];
    [render reloadData];

    //刷新用户数据
    [self refreshUserData];
    
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc
    (self.runningCoords.count * sizeof(CLLocationCoordinate2D));
    
    
    for (int i = 0; i < self.runningCoords.count; i ++) {
    CLLocation *location = self.runningCoords[i];
    coordinateArray[i] = location.coordinate;
    }
    
    MAPolyline *line = [MAPolyline polylineWithCoordinates:coordinateArray count:
                        self.runningCoords.count];
     
    [self.polyLines addObject:line];
     
    [self.mapView addOverlay:line];
     
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake
    (screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.mapView setVisibleMapRect:line.boundingMapRect edgePadding:inset animated:NO];


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
    
    [self.mapView removeOverlays:self.polyLines];  //移除画线
    [self.mapView removeAnnotations:self.annotations]; //移除所有的标注
    [self.annotations removeAllObjects];
    //移除热力图并刷新
    [self.mapView removeOverlays:self.headOverLines];
    [self.headOverLines removeAllObjects];
    [self.heatMapTileOverlay setOpacity:0];
    
    MATileOverlayRenderer *render = (MATileOverlayRenderer *)[self.mapView rendererForOverlay:
                                                              self.heatMapTileOverlay];
    [render reloadData];
    
    //刷新用户数据
    [self refreshUserData];
    
    //在地图上添加标注
    [self addAnnotation];

    
}
#pragma mark -是否显示热力图
- (void)showHeadMapOverLay:(UIButton *)btn{
    NSString *str =[USER_D objectForKey:@"showHeatOverlay"];
    NSString *trafficString;
    if ([str isEqualToString:@"YES"]) {
        trafficString = @"NO";
        [self showMyFriendLocation];
        [btn setBackgroundImage:[UIImage imageNamed:@"fence_close"] forState:0];
    }else{
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
            self.mapView.showTraffic = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"traffic_close"] forState:0];
        }else{
            self.mapView.showTraffic = YES;
            [btn setBackgroundImage:[UIImage imageNamed:@"traffic_open"] forState:0];
        }
    }else {
        self.mapView.showTraffic = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"traffic_open"] forState:0];
    }
    NSString *trafficString = self.mapView.showTraffic?@"YES":@"NO";
    [USER_D setObject:trafficString forKey:@"showTraffic"];
    [USER_D synchronize];
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
            [self showHeadMapOverLay:button];
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
        self.mapView.mapType = MAMapTypeSatellite;
    }else{
        self.mapView.mapType = MAMapTypeStandard;
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
    
    /* Add a annotation on map center. */
//    [self addAnnotationWithCooordinate:self.mapView.centerCoordinate];
    
}
#pragma mark -配置热力图
- (void)addHeatOverlay{
    
    [self.mapView removeOverlays:self.polyLines];
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    [self.heatMapTileOverlay setOpacity:1.0];
    //刷新用户数据
    [self refreshUserData];
 
    NSMutableArray *distanceArr = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *needIntensityEqual1 = [[NSMutableArray alloc]initWithCapacity:0];
    //计算两点之间的距离 放到distanceArr
    UserModel *mySelf = [[UserManager shareManager]getUser];
    MAMapPoint point1 = MAMapPointForCoordinate
    (CLLocationCoordinate2DMake(mySelf.lattitude.floatValue,mySelf.longitude.floatValue));
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
//    });;
    
    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
            (user.lattitude.floatValue, user.longitude.floatValue);
            
            MAMapPoint point2 = MAMapPointForCoordinate(coordinate);

            //计算两点之间的距离
            CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
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
        
        MAMapPoint point2 = MAMapPointForCoordinate(coordinate);
        //计算两点之间的距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        NSDictionary *userDistance = @{@"distance":@(distance),@"userId":userId,
                                        @"lattitude":dic[@"lat"],@"longitude":dic[@"lng"]};
        [distanceArr addObject:userDistance];

    }
    
    //判断两个点之间距离是否小于300 如果小于 放到needIntensityEqual1 并将它的热点intensity 设置为1 否则设置0.3
    
    for (int i = 0; i < distanceArr.count - 1; i ++) {
        for (int j = i + 1; j < distanceArr.count - 1; j ++) {
            NSDictionary *d1 = distanceArr[i];
            NSDictionary *d2 = distanceArr[j];
            
            if (fabsf([d1[@"distance"] floatValue] - [d2[@"distance"] floatValue]) < 100) {
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
        MAHeatMapNode *node = [[MAHeatMapNode alloc]init];
        node.coordinate = coordinate;
        node.intensity = 0.3;
        if ([needIntensityEqual1 containsObject:user]) {
            node.intensity = 1.0;
        }
        
        [self.headOverLines addObject:node];
    }
    
//    int i = 0;
//    for (NSDictionary *user in distanceArr) {
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
//        ([user[@"lattitude"] floatValue], [user[@"longitude"] floatValue]);
//        i ++ ;
//        //热力图标注
//        MAHeatMapNode *node = [[MAHeatMapNode alloc]init];
//        node.coordinate = coordinate;
//        
////        if (i%20 == 0) {
//            node.intensity = 0.3;
////        }else{
////            node.intensity = 1;
////        }
//        [self.headOverLines addObject:node];
//    }
    
    self.heatMapTileOverlay.data = self.headOverLines;
    
//    self.heatMapTileOverlay.boundingMapRect = MAMapRectMake(31.203223, 121.52322, 200, 100);;
    [self.mapView addOverlay:self.heatMapTileOverlay];
    //设置热力图半径
    [self.heatMapTileOverlay setRadius:40.0];
    //设置热力图透明度
    [self.heatMapTileOverlay setOpacity:0.3];
    //设置热力图颜色
//    [self.heatMapTileOverlay
//     setGradient:[[MAHeatMapGradient alloc] initWithColor:
//  @[RGBACOLOR(238, 177, 183, 1), RGBACOLOR(233, 125, 152, 1),
//    RGBACOLOR(234, 67, 115, 1),RGBACOLOR(236, 51, 93, 1),RGBACOLOR(252, 4, 66, 1)]
//    andWithStartPoints:@[@(0.2), @(0.4),@(0.6),@(0.8),@(0.9)]]];
    
    [self.heatMapTileOverlay
     setGradient:[[MAHeatMapGradient alloc] initWithColor:@[
                                                            [UIColor blueColor],
                                                            [UIColor greenColor],
                                                            [UIColor redColor]]
                                       andWithStartPoints:@[@(0.2)
                                                            ,@(0.5),@(0.9)]]];
    
//    [self.heatMapTileOverlay
//     setGradient:[[MAHeatMapGradient alloc] initWithColor:
//                  @[RGBACOLOR(236, 51, 93, 1), RGBACOLOR(236, 51, 93, 1),
//                    RGBACOLOR(236, 51, 93, 1),RGBACOLOR(236, 51, 93, 1),RGBACOLOR(252, 4, 66, 1)]
//                                       andWithStartPoints:@[@(0.2), @(0.4),@(0.6),@(0.8),@(0.9)]]];
    
    MATileOverlayRenderer *render = (MATileOverlayRenderer *)[self.mapView rendererForOverlay:
                                                              self.heatMapTileOverlay];
    self.heatMapTileOverlay.allowRetinaAdapting = YES;

    [render reloadData];
    //224888231.793110  109702693.191105 24.474865  39.967790
//    [self.mapView setVisibleMapRect: MAMapRectMake(224888240.793110, 109702693.191105,
//                                                   24.474865, 39.967790)
//                           animated:YES];
    //更新位置
    /*
    MAMapPoint annotationPoint = MAMapPointForCoordinate
    (CLLocationCoordinate2DMake(mySelf.lattitude.floatValue, mySelf.longitude.floatValue));
    MAMapRect pointRect = MAMapRectMake(annotationPoint.x, annotationPoint.y, 10, 10);
    [self.mapView mapRectThatFits:pointRect];
    [self.mapView setVisibleMapRect:pointRect animated:YES];
     */
    
}
#pragma mark -配置标注
-(void)addAnnotation
{

    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            //标注
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
            (user.lattitude.floatValue,user.longitude.floatValue);
            annotation.coordinate = coordinate;
            annotation.title    = user.userNick;
            annotation.subtitle = user.userId;
            [self.annotations addObject:annotation];

        }
    }
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations edgePadding:
     UIEdgeInsetsMake(0, 20, 0, 20) animated:YES];

}
- (void)initSearch
{
    
    self.search = [[AMapSearchAPI alloc]init];
    self.search.delegate = self;

}
- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
//    self.mapView.showsCompass = NO;   //是否显示罗盘
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;  //跟随模式  持续更新用户定位
//    self.mapView.showsUserLocation = YES;
//    self.mapView.showsUserLocation = NO;
//    self.mapView.userTrackingMode = MAUserTrackingModeNone;
//    self.mapView.zoomEnabled = YES; //是否支持缩放
//    self.mapView.zoomLevel = 12.0; //缩放级别
//    self.mapView.zoomLevel = self.mapView.minZoomLevel;  //最小缩放级别
    //    [self.mapView setCompassImage:[UIImage imageNamed:@"bg-x@2x"]];//罗盘图片
    [self.view addSubview:self.mapView];
    
    self.heatMapTileOverlay = [[MAHeatMapTileOverlay alloc]init];
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
#pragma -mark 地理位置编码
- (void)getFGocode:(NSString*)address{

}
#pragma mark - AMapSearchDelegate  地理位置编码  回调方法
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request
                   response:(AMapGeocodeSearchResponse *)response
{

}
#pragma -mark 反地理位置编码
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{

}
#pragma -mark 反地理位置编码  回调方法
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request
                     response:(AMapReGeocodeSearchResponse *)response
{
    //response.regeocode
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode
       animated:(BOOL)animated
{
    
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation{

    
    NSLog(@"1");
    
    if (userLocation.location.coordinate.latitude == 0 ||
        userLocation.location.coordinate.longitude == 0) {
        return;
    }
    CLLocation *nowLocation = [[CLLocation alloc]initWithLatitude:
    userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    [self.runningCoords addObject:nowLocation];
    
 
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    //画线
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *po = [[MAPolylineRenderer alloc]initWithPolyline:overlay];
        po.lineWidth = 8;
        po.strokeColor = [UIColor blueColor];
        
        return po;
    }
    
    //热力图
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayRenderer *render = [[MATileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
        return render;
    }
    
    return nil;
}
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{

}
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{

    /* Adjust the map center in order to show the callout view completely. */
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake
        (kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* Calculate the offset to make the callout view show up. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter
                                                      toCoordinateFromView:self.mapView];
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    NSLog(@"11111");
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *identifier = @"customViewId";
        
        CustomAnnotationView *annotationView = [[CustomAnnotationView alloc]initWithAnnotation:
                                                annotation reuseIdentifier:identifier];
        //必须设置no 不然没法设置自定义弹出view
        annotationView.canShowCallout = NO;
        annotationView.customDelegate = self;
        annotationView.draggable = YES;
//        annotationView.calloutOffset = CGPointMake(0, -5);
//        annotationView.portrait = [UIImage imageNamed:@"NexFiIcon"];
        UserModel *user = [self getUserFromAnnotationWithUserId:annotation.subtitle];
        NSLog(@"ann===%@===",annotation.title);
        annotationView.portrait = [UIImage imageNamed:user.userAvatar];
        annotationView.name     = user.userNick;
         
        /*
        MAPinAnnotationView *annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        annotationView.draggable                    = YES;
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        NSLog(@"ann===%@===",annotation.title);
        return annotationView;
         */
        
        return annotationView;
    }

    return nil;
    
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
