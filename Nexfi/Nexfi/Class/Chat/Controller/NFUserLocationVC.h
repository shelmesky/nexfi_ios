//
//  NFUserLocationVC.h
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"


#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件


@interface NFUserLocationVC : BaseVC



@property (nonatomic, strong) BMKMapView *bdMapView;

@property (nonatomic, strong) NSMutableArray *friendList;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *trafficBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapOverLayBtn;
@end
