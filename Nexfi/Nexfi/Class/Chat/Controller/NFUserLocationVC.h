//
//  NFUserLocationVC.h
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapSearchKit/AMapSearchObj.h>


@interface NFUserLocationVC : BaseVC

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) NSMutableArray *friendList;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *trafficBtn;
@end
