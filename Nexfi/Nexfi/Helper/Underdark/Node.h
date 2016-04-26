//
//  Node.h
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UDSource.h"
#import "Underdark.h"
#import "UDTransport.h"
#import "ViewController.h"
#import "NFSingleChatInfoVC.h"
#import "NeighbourVC.h"
#import "NFAllUserChatInfoVC.h"


@protocol NodeDelegate <NSObject>
//发送消息失败
- (void)singleChatSendFailWithInfo:(NSString *)failMsg;
- (void)AllUserChatSendFailWithInfo:(NSString *)failMsg;

@end

@interface Node : NSObject<UDTransportDelegate>

@property (nonatomic, strong)NSString *usersId;
@property (nonatomic,strong)NeighbourVC *neighbourVc;
@property (nonatomic,strong)NFSingleChatInfoVC *singleVC;
@property (nonatomic,strong)NFAllUserChatInfoVC *allUserChatVC;

@property (nonatomic ,strong)id<UDTransport>transport;
@property (nonatomic, assign)int peersCount;
@property (nonatomic, assign)int framesCount;
@property (nonatomic, assign)int bytesCount;
@property (nonatomic, assign)int appId;
@property (nonatomic, assign)long  int nodeId;
@property (nonatomic, assign)NSTimeInterval timeStart;
@property (nonatomic, assign)NSTimeInterval timeEnd;
@property (nonatomic, strong)dispatch_queue_t queue;
@property (nonatomic, strong)NSMutableArray *links;
@property (nonatomic ,strong)id<UDLink>link;

@property (nonatomic, assign)id<NodeDelegate>delegate;

- (void)start;
- (void)stop;
//- (void)broadcastFrame:(id<UDSource>)frameData;
- (id<UDSource>)sendMsgWithMessageType:(MessageType)type;
- (void)broadcastFrame:(id<UDSource>)frameData WithMessageType:(MessageType)messageType;
//转发
- (void)groupSendBroadcastFrame:(id<UDSource>)frameData WithtribeMessage:(TribeMessage *)msg;
- (id<UDSource>)frameDatawithTribeMessage:(TribeMessage *)msg;
@end
