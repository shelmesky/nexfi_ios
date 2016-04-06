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
#import "ChatInfoVC.h"

@interface Node : NSObject<UDTransportDelegate>

@property (nonatomic,strong)ChatInfoVC *controller;
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


- (void)start;
- (void)stop;
- (void)broadcastFrame:(id<UDSource>)frameData;
@end
