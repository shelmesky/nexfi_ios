//
//  TribeMessage.m
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "TribeMessage.h"

@implementation TribeMessage

- (id)initWithaDic:(NSDictionary *)aDic{
    if (self = [super init]) {
        
        self.timestamp = aDic[@"timestamp"];
        self.msgId = aDic[@"msgId"];
        self.sender = aDic[@"sender"];
        self.senderNickName = aDic[@"senderNickName"];
        self.senderFaceImageStr = aDic[@"senderFaceImageStr"];
        self.fileType = [aDic[@"fileType"] intValue];
        self.messageType = [aDic[@"messageType"] intValue];
        self.nodeId = aDic[@"nodeId"];
        self.durational = aDic[@"durational"];
        self.file = aDic[@"file"];
        self.groupId = aDic[@"groupId"] ;
        self.isRead = aDic[@"isRead"] ;
        self.tContent = aDic[@"tContent"];
        
    }
    return self;
}

@end
