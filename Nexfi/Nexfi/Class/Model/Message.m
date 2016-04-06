//
//  Message.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "Message.h"

@implementation Message
- (id)initWithaDic:(NSDictionary *)aDic{
    if ( self = [super init]) {
        self.timestamp = aDic[@"timestamp"];
        self.durational = aDic[@"durational"];
        self.msgId = aDic[@"msgId"];
        self.receiver = aDic[@"receiver"];
        self.sender = aDic[@"sender"];
        self.senderNickName = aDic[@"senderNickName"];
        self.senderFaceImage = aDic[@"senderFaceImage"];
        
        self.fileType = aDic[@"fileType"];
        self.mid = aDic[@"mid"];
        self.type = aDic[@"type"];
        self.title = aDic[@"title"];
        self.content = aDic[@"content"];
        self.file = aDic[@"file"];

    }
    return self;
}
@end
