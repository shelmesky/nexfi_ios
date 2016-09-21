//
//  AppDelegate.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong , nonatomic) CLLocationManager *location;
@property (nonatomic, retain) UITabBarController *tabbar;

@end

