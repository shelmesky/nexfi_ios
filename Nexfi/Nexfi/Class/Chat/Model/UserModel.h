//
//  UserModel.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, retain) NSString *userId;//用户id
@property (nonatomic, retain) NSString *userNick;//用户昵称
@property (nonatomic, retain) NSString *userGender;//用户性别
@property (nonatomic, assign) int userAge;//用户年龄
@property (nonatomic, retain) NSString *userAvatar;//用户头像
@property (nonatomic, retain) NSString *nodeId;//用户nodeId
@property (nonatomic, retain) NSString *birthday;//用户生日

@property (nonatomic,retain) NSString *phoneNumber;//手机号


- (id)initWithaDic:(NSDictionary *)aDic;

@end
