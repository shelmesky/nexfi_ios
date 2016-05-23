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

@property (nonatomic, retain) NSString *durational;//语音时间
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSString *tContent;
@property (nonatomic, retain) NSString *groupId;//群组的时候用
@property (nonatomic, retain) NSString *isRead;//0未读 1已读


- (id)initWithaDic:(NSDictionary *)aDic;


@end
