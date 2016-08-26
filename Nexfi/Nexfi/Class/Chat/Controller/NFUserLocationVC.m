//
//  NFUserLocationVC.m
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

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
@property (nonatomic, strong) MapTypeView *mapTypeView;
@end

@implementation NFUserLocationVC
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.isNeedUpdate = YES;
    
//    [self getUserLocation];
    
    [self initMapView];
    
    
    [self configureTrifficAndMap];

    [self setBaseVCAttributesWith:@"附近的人" left:nil right:nil WithInVC:self];
    UIBarButtonItem *show = [[UIBarButtonItem alloc]initWithTitle:@"我的轨迹" style:UIBarButtonItemStylePlain target:self action:@selector(showLine:)];
    self.navigationItem.rightBarButtonItem = show;
    
    _isShow = NO;
    
    [self showMyFriendLocation];
    //3分钟更新下用户位置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFriendInfo) name:@"updateFriendInfo" object:nil];
    
}
- (void)updateFriendInfo{
    [self showMyFriendLocation];
}
- (void)configureTrifficAndMap{
    NSString *trafficStr =[USER_D objectForKey:@"showTraffic"];
    if (trafficStr.length>0) {
        if ([trafficStr isEqualToString:@"YES"]) {
            self.mapView.showTraffic = YES;
            UIButton *trafficBtn = (UIButton *)[self.view viewWithTag:1001];
            [trafficBtn setBackgroundImage:[UIImage imageNamed:@"traffic_open"] forState:0];
        }else{
            self.mapView.showTraffic = NO;
        }
    }
    NSString *typeStr = [USER_D objectForKey:@"MAMapType"];
    if (typeStr.length>0)
    {
        if ([typeStr isEqualToString:@"卫星图"]) {
            self.mapView.mapType = MAMapTypeSatellite;
        }else{
            self.mapView.mapType = MAMapTypeStandard;
        }
    }else{
        self.mapView.mapType = MAMapTypeStandard;
    }
    
    [self.view bringSubviewToFront:self.trafficBtn];
    [self.view bringSubviewToFront:self.mapTypeBtn];
}
- (void)showMyPolyLine{
    
     //移除标注
     [self.mapView removeAnnotations:self.annotations];
     
     CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc(self.runningCoords.count * sizeof(CLLocationCoordinate2D));
    
    
     for (int i = 0; i < self.runningCoords.count; i ++) {
     CLLocation *location = self.runningCoords[i];
     coordinateArray[i] = location.coordinate;
     }
     
     MAPolyline *line = [MAPolyline polylineWithCoordinates:coordinateArray count:self.runningCoords.count];
     
     [self.polyLines addObject:line];
     
     [self.mapView addOverlay:line];
     
     const CGFloat screenEdgeInset = 20;
     UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
     [self.mapView setVisibleMapRect:line.boundingMapRect edgePadding:inset animated:NO];
     

}
- (void)showMyFriendLocation{
    
    //移除画线
    [self.mapView removeOverlays:self.polyLines];
    [self.mapView removeAnnotations:self.annotations];
    
    for (UIViewController *v in self.navigationController.viewControllers) {
        if ([v isKindOfClass:[NeighbourVC class]]) {
            NeighbourVC *neighbourVc = (NeighbourVC *)v;
            self.friendList = [[NSMutableArray alloc]initWithArray:neighbourVc.handleByUsers];
        }
    }
    
    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            [self addAnnotationWithUserModel:user];
            
        }
    }
    
    [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(10, 10, 100, 100) animated:YES];
    
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

            _mapTypeView = [[MapTypeView alloc] initWithFrame:CGRectMake(button.frame.origin.x+width-223, button.y + button.height, 223, 100)];
            _mapTypeView.delegate = self;
            [self.view addSubview:_mapTypeView];
            [_mapTypeBtn setBackgroundImage:[UIImage imageNamed:@"close_map_Type_tip"] forState:0];
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
-(void)addAnnotationWithUserModel:(UserModel *)user
{
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(user.lattitude.floatValue, user.longitude.floatValue);
    annotation.coordinate = coordinate;
    annotation.title    = user.userNick;
    annotation.subtitle = user.userId;
    
    [self.annotations addObject:annotation];
    
    [self.mapView addAnnotation:annotation];
    
//    [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(10, 10, 100, 100) animated:YES];

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
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{

}
#pragma -mark 反地理位置编码
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{

}
#pragma -mark 反地理位置编码  回调方法
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    //response.regeocode
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{

    
    NSLog(@"1");
    
    if (userLocation.location.coordinate.latitude == 0 || userLocation.location.coordinate.longitude == 0) {
        return;
    }
    CLLocation *nowLocation = [[CLLocation alloc]initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    [self.runningCoords addObject:nowLocation];
    
 
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
//        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
//        
//        polylineRenderer.lineWidth = 8.f;
//        polylineRenderer.strokeColors = _speedColors;
//        polylineRenderer.gradient = YES;
        
        MAPolylineRenderer *po = [[MAPolylineRenderer alloc]initWithPolyline:overlay];
        po.lineWidth = 8;
        po.strokeColor = [UIColor blueColor];
        
        return po;
    }
    
    return nil;
}
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

}
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{

    /* Adjust the map center in order to show the callout view completely. */
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* Calculate the offset to make the callout view show up. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
            
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
    
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *identifier = @"customViewId";
        CustomAnnotationView *annotationView = [[CustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        //必须设置no 不然没法设置自定义弹出view
        annotationView.canShowCallout = NO;
        annotationView.customDelegate = self;
        annotationView.draggable = YES;
        annotationView.calloutOffset = CGPointMake(0, -5);
//        annotationView.portrait = [UIImage imageNamed:@"NexFiIcon"];
        UserModel *user = [self getUserFromAnnotationWithUserId:annotation.subtitle];
        annotationView.portrait = [UIImage imageNamed:user.userAvatar];
        annotationView.name     = user.userNick;
        
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
