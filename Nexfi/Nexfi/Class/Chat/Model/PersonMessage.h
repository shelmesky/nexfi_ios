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
@property (nonatomic, retain) NSString *isRead;//0未读 1已读


- (id)initWithaDic:(NSDictionary *)aDic;

@end
