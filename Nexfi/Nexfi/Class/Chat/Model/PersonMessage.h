//
//  Message.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "TextMessage.h"
#import "FileMessage.h"
#import "VoiceMessage.h"

@interface PersonMessage : Message


@property (nonatomic, retain) NSString *receiver;//接收者

@property (nonatomic, retain) TextMessage *textMessage;//文本
@property (nonatomic, retain) FileMessage *fileMessage;//图片
@property (nonatomic, retain) VoiceMessage *voiceMessage;//语音




@end
