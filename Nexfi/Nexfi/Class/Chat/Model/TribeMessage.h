//
//  TribeMessage.h
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
@interface TribeMessage : Message


@property (nonatomic, retain) NSString *groupId;//群组的时候用

@property (nonatomic, retain) TextMessage *textMessage;
@property (nonatomic, retain) FileMessage *fileMessage;
@property (nonatomic, retain) VoiceMessage *voiceMessage;



@end
