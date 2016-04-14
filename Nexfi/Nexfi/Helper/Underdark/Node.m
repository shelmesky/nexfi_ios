//
//  Node.m
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "MTLJSONAdapter.h"
#import "UserModel.h"
#import "NexfiUtil.h"
#import "UserManager.h"
#import "Node.h"
#import "DDLog.h"
#import "UDLink.h"
@implementation Node
- (id)init{
    if (self = [super init]) {
        _links = [[NSMutableArray alloc]initWithCapacity:0];
        _appId = 234235;
        _queue = dispatch_get_main_queue();
        
        long long int buf = 0;
        do {
            arc4random_buf(&buf, sizeof(buf));
            
        } while (buf == 0);
        
        if (buf < 0) {
            buf = -buf;
        }
        
        _nodeId = buf;
        

        
        NSMutableArray *transportKinds = [[NSMutableArray alloc]initWithCapacity:0];
        [transportKinds addObject:[NSNumber numberWithInt:UDTransportKindWifi]];
        [transportKinds addObject:[NSNumber numberWithInt:UDTransportKindBluetooth]];
        
        _transport = [UDUnderdark configureTransportWithAppId:_appId nodeId:_nodeId delegate:self queue:_queue kinds:transportKinds];
        
    }

    
    return self;
    
    
}
- (void)start{
//    [self.controller updateFramesCount];
//    [self.controller updatePeerCount];

    [_transport start];
    
}
- (void)stop{
    
    [self.transport stop];
    _framesCount = 0;
//    [self.controller updateFramesCount];
    
}
- (void)broadcastFrame:(id<UDSource>)frameData{
    if (_links.count == 0) {
        return;
    }
//    [self.controller updateFramesCount];
    for (int i = 0; i < self.links.count; i ++) {
        self.link = [self.links objectAtIndex:i];
        [self.link sendData:frameData];
    }

}
- (id<UDSource>)sendMsgWithMessageType:(MessageType)type WithConnectedLink:(id<UDLink>)link{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        NSData *data;
        if (type == eMessageType_requestUserInfo) {//请求用户信息
            NSDictionary *userDic = @{@"messageType":[NSString stringWithFormat:@"%ld",eMessageType_requestUserInfo]};
            data = [NSJSONSerialization dataWithJSONObject:userDic options:0 error:0];
            
            
        }else if(type == eMessageType_SendUserInfo){//发送用户信息
            UserModel *user = [[UserManager shareManager]getUser];
            user.nodeId = [NSString stringWithFormat:@"%lld",link.nodeId];

            NSDictionary *userDic = [NexfiUtil getObjectData:user];
            NSMutableDictionary *usersDic = [[NSMutableDictionary alloc]initWithDictionary:userDic];
            [usersDic setObject:[NSString stringWithFormat:@"%ld",eMessageType_SendUserInfo] forKey:@"messageType"];

            data = [NSJSONSerialization dataWithJSONObject:usersDic options:0 error:0];
            
            
        }
        return data;
        
    }];
    
    return result;
}
#pragma -mark UDTransportDelegate
- (void)transport:(id<UDTransport>)transport linkConnected:(id<UDLink>)link{
    [self.links addObject:link];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [link sendData:[self sendMsgWithMessageType:eMessageType_requestUserInfo WithConnectedLink:link]];

//    });
    
    
    self.peersCount += 1;
    self.neighbourVc.peesCount = [NSString stringWithFormat:@"%d",self.peersCount];
    if (self.allUserChatVC) {
        [self.allUserChatVC updatePeersCount:[NSString stringWithFormat:@"%d",self.peersCount]];
    }
}
- (void)transport:(id<UDTransport>)transport linkDisconnected:(id<UDLink>)link{
    
    if ([self.links containsObject:link]) {
        [self.links removeObject:link];
    }
    
    self.peersCount -= 1;
    
    self.neighbourVc.peesCount = [NSString stringWithFormat:@"%d",self.peersCount];
    if (self.allUserChatVC) {
        [self.allUserChatVC updatePeersCount:[NSString stringWithFormat:@"%d",self.peersCount]];
    }
    
    if (self.neighbourVc.handleByUsers.count == 0) {
        return;
    }

    [self.neighbourVc.handleByUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UserModel *user = obj;
        if ([user.nodeId isEqualToString:[NSString stringWithFormat:@"%lld",link.nodeId]]) {
            BOOL stop = YES;;
            if (stop == YES) {
                [self.neighbourVc.handleByUsers removeObject:user];
                
            }
            
            [self.neighbourVc.usersTable reloadData];
            
        }

    }];
            
}
- (void)transport:(id<UDTransport>)transport link:(id<UDLink>)link didReceiveFrame:(NSData *)frameData{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:frameData options:0 error:0];
    switch ([dic[@"messageType"] intValue]) {
        case eMessageType_requestUserInfo:
        {
            [link sendData:[self sendMsgWithMessageType:eMessageType_SendUserInfo WithConnectedLink:link]];
            break;
        }
        case eMessageType_SendUserInfo:
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfo" object:nil userInfo:@{@"user":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
            break;
        }
        case eMessageType_SingleChat:
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"singleChat" object:nil userInfo:@{@"text":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
            break;
        }
        case eMessageType_AllUserChat:
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"allUser" object:nil userInfo:@{@"text":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
            break;
        }
        default:
            break;
    }

}

@end
