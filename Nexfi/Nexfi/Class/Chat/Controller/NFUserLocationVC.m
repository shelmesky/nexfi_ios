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


#define kCalloutViewMargin          -8


@interface NFUserLocationVC ()<MAMapViewDelegate,CustomAnnotationDelegate>

@property (nonatomic, retain)NSMutableArray *annotations;

@end

@implementation NFUserLocationVC
- (NSMutableArray *)annotations{
    if (!_annotations) {
        _annotations = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _annotations;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initMapView];
    [self initSearch];

    for (UserModel *user in self.friendList) {
        if (user && user.lattitude && user.longitude) {
            [self addAnnotationWithUserModel:user];
        }
    }
    
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
    
    [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(10, 10, 100, 100) animated:YES];

}
- (void)initSearch
{
    
    
    self.search = [[AMapSearchAPI alloc]init];
    self.search.delegate = self;

    
    
}
- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    
    self.mapView.showsCompass = NO;   //是否显示罗盘
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;  //跟随模式  持续更新用户定位
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES; //是否支持缩放
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

//    self.mapView.userTrackingMode = MAUserTrackingModeNone;  //不追踪用户的location更新
    
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
        NSLog(@"user==%@",user.mj_keyValues);
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
