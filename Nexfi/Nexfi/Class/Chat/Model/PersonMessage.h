//
//  Message.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
@interface PersonMessage : Message


@property (nonatomic, retain) NSString *durational;//语音时间
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSString *receiver;//接收者
@property (nonatomic, retain) NSString *pContent;


@property (nonatomic, retain) NSString *timestamp;//发送时间
@property (nonatomic, retain) NSString *msgId;//消息id
@property (nonatomic, retain) NSString *sender;//发送此条消息的id
@property (nonatomic, retain) NSString *senderNickName;
@property (nonatomic, retain) NSString *senderFaceImageStr;
@property (nonatomic, assign) MessageBodyType fileType;//文件类型
@property (nonatomic, assign) MessageType messageType;
@property (nonatomic, retain) NSString *nodeId;

- (id)initWithaDic:(NSDictionary *)aDic;

@end
