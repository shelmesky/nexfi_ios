//
//  Message.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "Message.h"

@implementation PersonMessage

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
        self.receiver = aDic[@"receiver"] ;
        self.pContent = aDic[@"pContent"];

    }
    return self;
}

@end
