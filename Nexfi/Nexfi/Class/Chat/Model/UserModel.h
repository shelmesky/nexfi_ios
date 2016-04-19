//
//  UserModel.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UDLink.h"
#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, retain) NSString *userId;//
@property (nonatomic, retain) NSString *userName;//
@property (nonatomic, retain) NSString *sex;//
@property (nonatomic, retain) NSString *age;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *headImgStr;
@property (nonatomic, retain) NSString *headImgPath;

@property (nonatomic, retain) NSString *nodeId;

@property (nonatomic, retain) NSString *unreadnum;
@property (nonatomic, retain) NSString *lastmsg;
@property (nonatomic, retain) NSString *send_time;


//@property (nonatomic, retain) UIImage *headImg;

- (id)initWithaDic:(NSDictionary *)aDic;

@end
