//
//  TribeMessage.h
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TribeMessage : NSObject

@property (nonatomic, retain) NSString *timestamp;//发送时间
@property (nonatomic, retain) NSString *durational;//语音时间
@property (nonatomic, retain) NSString *msgId;//消息id

@property (nonatomic, retain) NSString *sender;//自己的id
@property (nonatomic, retain) NSString *senderNickName;
@property (nonatomic, retain) NSString *senderFaceImageStr;
@property (nonatomic, retain) NSString *fileType;//文件类型

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;//内容
@property (nonatomic, retain) NSString *file;


@property (nonatomic, retain) NSString *isRead;
@property (nonatomic, retain) NSString *groupId;

@property (nonatomic, retain) NSString *nodeId;

@end
