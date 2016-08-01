//
//  NeighbourVC.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "BaseVC.h"
#import <UIKit/UIKit.h>

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapSearchKit/AMapSearchObj.h>

@interface NeighbourVC : BaseVC

@property (nonatomic,strong) UITableView *usersTable;
@property (nonatomic,strong) NSMutableArray *nearbyUsers;
@property (nonatomic,strong) NSMutableArray *handleByUsers;

@property (nonatomic,strong) NSMutableArray *nodeList;

@property (nonatomic ,retain) NSString *peesCount;

@property (nonatomic, strong) MAMapView *mapView;


- (NSMutableArray *)getAllNodeId;
- (void)refreshTable:(NSDictionary *)userJson;
@end
