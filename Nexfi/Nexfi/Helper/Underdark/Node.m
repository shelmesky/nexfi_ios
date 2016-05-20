//
//  Node.m
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
//#import "MTLJSONAdapter.h"
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
        

        //优先选择WIFI
        NSMutableArray *transportKinds = [[NSMutableArray alloc]initWithCapacity:0];
        [transportKinds addObject:[NSNumber numberWithInt:UDTransportKindWifi]];
        [transportKinds addObject:[NSNumber numberWithInt:UDTransportKindBluetooth]];
        
        _transport = [UDUnderdark configureTransportWithAppId:_appId nodeId:_nodeId delegate:self queue:_queue kinds:transportKinds];
        
    }

    
    return self;
    
    
}
/**
 *开启蓝牙/WIFI 监测
 */
- (void)start{

    [self.transport start];
    
}
/**
 *关闭蓝牙/WIFI 监测
 */
- (void)stop{
    
    [self.transport stop];
    
}
#pragma -mark 群发数据
- (id<UDSource>)frameDatawithTribeMessage:(TribeMessage *)msg{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
        NSData *newData;
        
        
//        NSDictionary *msgDic = [NexfiUtil getObjectData:msg];
        newData = [NSJSONSerialization dataWithJSONObject:msg.mj_keyValues options:0 error:0];
        
        
        return newData;
        
    }];
    
    return result;
}

#pragma -mark 转发
- (void)groupSendBroadcastFrame:(id<UDSource>)frameData WithtribeMessage:(TribeMessage *)msg{
    if (self.links.count == 0) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(AllUserChatSendFailWithInfo:)]) {
            [self.delegate AllUserChatSendFailWithInfo:@"您附近没有用户上线哦~"];
        }
        
        return;
    }
    for (int i = 0; i < self.links.count; i ++) {
        id<UDLink>myLink = [self.links objectAtIndex:i];
        //不重复发给之前发我消息的人
//        if (![[NSString stringWithFormat:@"%lld",myLink.nodeId] isEqualToString:msg.nodeId]) {
            [myLink sendData:frameData];

//        }
    }
    
}
/**
 *单聊发送消息接口
 *frameData参数由此函数获得 UDLazySource *r = [UDLazySource alloc]initWithQueue:<#(nullable dispatch_queue_t)#> block:<#^NSData * _Nullable(void)block#>
 */
- (void)singleChatWithFrame:(id<UDSource>)frameData{
    //获取与该用户的link发送数据
    id<UDLink>myLink = [self.singleVC getUserLink];
    if (myLink) {
        [myLink sendData:frameData];
    }else{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(singleChatSendFailWithInfo:)]) {
            [self.delegate singleChatSendFailWithInfo:@"该用户已经下线"];
        }
    }
}
/**
 *群聊发送消息接口
 *frameData参数由此函数获得 UDLazySource *r = [UDLazySource alloc]initWithQueue:<#(nullable dispatch_queue_t)#> block:<#^NSData * _Nullable(void)block#>
 */
- (void)allUserChatWithFrame:(id<UDSource>)frameData{
    //没有连接群聊发送消息失败
    if (self.links.count == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AllUserChatSendFailWithInfo:)]) {
            [self.delegate AllUserChatSendFailWithInfo:@"您附近没有用户上线哦~"];
        }
        return;
    }
    for (int i = 0; i < self.links.count; i ++) {
        id<UDLink>myLink = [self.links objectAtIndex:i];
        
        [myLink sendData:frameData];
    }

}
- (void)broadcastFrame:(id<UDSource>)frameData WithMessageType:(MessageType)messageType{
    switch (messageType) {
            
        case eMessageType_SingleChat:
        {
            //获取与该用户的link发送数据
            id<UDLink>myLink = [self.singleVC getUserLink];
            if (myLink) {
                [myLink sendData:frameData];
            }else{
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(singleChatSendFailWithInfo:)]) {
                    [self.delegate singleChatSendFailWithInfo:@"该用户已经下线"];
                }
            }
            break;
        }
        case eMessageType_AllUserChat:
        {
            //没有连接群聊发送消息失败
            if (self.links.count == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(AllUserChatSendFailWithInfo:)]) {
                    [self.delegate AllUserChatSendFailWithInfo:@"您附近没有用户上线哦~"];
                }
                return;
            }
            for (int i = 0; i < self.links.count; i ++) {
                id<UDLink>myLink = [self.links objectAtIndex:i];
                
                [myLink sendData:frameData];
            }

            break;
        }
        default:
            break;
    }
    
    
}
/**
 *发送 用户信息请求消息 （eMessageType_requestUserInfo）用户信息返回消息 （eMessageType_SendUserInfo）
 *更新用户信息 （eMessageType_UpdateUserInfo）  
 *MessageType  自己定义
 */
- (id<UDSource>)sendMsgWithMessageType:(MessageType)type{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        NSData *data;
        if (type == eMessageType_requestUserInfo) {//请求用户信息
            NSDictionary *userDic = @{@"messageType":[NSString stringWithFormat:@"%ld",(long)eMessageType_requestUserInfo]};
            data = [NSJSONSerialization dataWithJSONObject:userDic options:0 error:0];
            
            
        }else if(type == eMessageType_SendUserInfo){//发送用户信息
            UserModel *user = [[UserManager shareManager]getUser];

//            NSDictionary *userDic = [NexfiUtil getObjectData:user];
            NSMutableDictionary *usersDic = [[NSMutableDictionary alloc]initWithDictionary:user.mj_keyValues];
            [usersDic setObject:[NSString stringWithFormat:@"%ld",(long)eMessageType_SendUserInfo] forKey:@"messageType"];

            data = [NSJSONSerialization dataWithJSONObject:usersDic options:0 error:0];
            
            
        }else if (type == eMessageType_UpdateUserInfo){//更新用户信息
            
            UserModel *user = [[UserManager shareManager]getUser];
            //            user.nodeId = [NSString stringWithFormat:@"%lld",link.nodeId];
            
//            NSDictionary *userDic = [NexfiUtil getObjectData:user];
            NSMutableDictionary *usersDic = [[NSMutableDictionary alloc]initWithDictionary:user.mj_keyValues];
            [usersDic setObject:[NSString stringWithFormat:@"%ld",(long)eMessageType_UpdateUserInfo] forKey:@"messageType"];
            
            data = [NSJSONSerialization dataWithJSONObject:usersDic options:0 error:0];
            
        }
        return data;
        
    }];
    
    return result;
}
#pragma -mark UDTransportDelegate
- (void)transport:(id<UDTransport>)transport linkConnected:(id<UDLink>)link{
    [self.links addObject:link];
    
    //请求用户信息接口
    [link sendData:[self sendMsgWithMessageType:eMessageType_requestUserInfo]];

    //更新用户数量
    self.peersCount += 1;
    
    self.neighbourVc.peesCount = [NSString stringWithFormat:@"%d",self.peersCount];
    
//    LogDebug(@"");
//    if (self.allUserChatVC) {
//        [self.allUserChatVC updatePeersCount:[NSString stringWithFormat:@"%d",self.peersCount]];
//    }
    
}
- (void)transport:(id<UDTransport>)transport linkDisconnected:(id<UDLink>)link{
    
    if ([self.links containsObject:link]) {
        [self.links removeObject:link];
    }
    //更新用户数量
    self.peersCount -= 1;
    
    self.neighbourVc.peesCount = [NSString stringWithFormat:@"%d",self.peersCount];
//    if (self.allUserChatVC) {
//        [self.allUserChatVC updatePeersCount:[NSString stringWithFormat:@"%d",self.peersCount]];
//    }
    
    if (self.neighbourVc.handleByUsers.count == 0) {
        return;
    }
    //更新附近的人页面用户
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
/**
 *用户接收消息接口  自定义消息类型区分不同类型的消息 messageType
 */
- (void)transport:(id<UDTransport>)transport link:(id<UDLink>)link didReceiveFrame:(NSData *)frameData WithProgress:(float)progress{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:frameData options:0 error:0];
    switch ([dic[@"messageType"] intValue]) {
        case eMessageType_requestUserInfo://请求用户信息
        {
            [link sendData:[self sendMsgWithMessageType:eMessageType_SendUserInfo]];
            break;
        }
        case eMessageType_SendUserInfo://发送用户信息
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfo" object:nil userInfo:@{@"user":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
            break;
        }
        case eMessageType_UpdateUserInfo://更新用户信息
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfo" object:nil userInfo:@{@"user":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId],@"update":@"1"}];
            
            NSMutableDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:dic];
            [user removeObjectForKey:@"nodeId"];
            [user setObject:[NSString stringWithFormat:@"%lld",link.nodeId] forKey:@"nodeId"];
            
            UserModel *users = [[UserModel alloc]initWithaDic:user];
            //更新数据库用户数据
            [[SqlManager shareInstance]updateUserName:users];
            [[SqlManager shareInstance]updateUserHead:users];

            break;
        }
        case eMessageType_SingleChat://单聊
        {
            if (self.singleVC && [self.singleVC.to_user.nodeId isEqualToString:[NSString stringWithFormat:@"%lld",link.nodeId]]) {//当前页面是单聊 并且发消息的人和当前页面聊天的人是同一个人
                NSDictionary *msgDic = @{@"text":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]};
                [self.singleVC refreshGetData:msgDic];
            }else{
                
                NSDictionary *text = dic;
                NSString *nodeId = [NSString stringWithFormat:@"%lld",link.nodeId];
                
                PersonMessage *msg = [[PersonMessage alloc]initWithaDic:text];
//                msg.nodeId = nodeId;
                if (msg.fileType != eMessageBodyType_Text && msg.file) {
                    msg.pContent = msg.file;
                }
                UserModel *user = [[UserModel alloc]init];
                //    user.headImgStr = msg.senderFaceImageStr;
                user.headImgPath = msg.senderFaceImageStr;
                user.userName = msg.senderNickName;
                user.userId = msg.sender;
                
                //保存聊天记录
                [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:user WithMsg:msg];
                //增加未读消息数量
                [[SqlManager shareInstance]addUnreadNum:[[UserManager shareManager]getUser].userId];
                
            }

            NSLog(@"收到了");
            break;
        }
        case eMessageType_AllUserChat://群聊
        {
            if (self.allUserChatVC) {//当前页面是群聊
                NSDictionary *msgDic = @{@"text":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]};
                [self.allUserChatVC refreshGetData:msgDic];
            }else{

                NSDictionary *text = dic;
                NSString *nodeId = [NSString stringWithFormat:@"%lld",link.nodeId];
                TribeMessage *msg = [[TribeMessage alloc]initWithaDic:text];
//                msg.nodeId = nodeId;
                if (msg.fileType != eMessageBodyType_Text && msg.file) {
                    msg.tContent = msg.file;
                }
                msg.isRead = @"1";
                UserModel *user = [[UserModel alloc]init];
                user.userId = msg.sender;
                user.userName = msg.senderNickName;
                //    user.headImgStr = msg.senderFaceImageStr;
                user.headImgPath = msg.senderFaceImageStr;
                
                //保存聊天记录
                [[SqlManager shareInstance]insertAllUser_ChatWith:user WithMsg:msg];
                //增加未读消息数量

            }

            break;
        }
        default:
            break;
    }

}
- (void) transport:(id<UDTransport>)transport link:(id<UDLink>)link fail:(NSString*)fail{
    
}
- (void)transport:(id<UDTransport>)transport link:(id<UDLink>)link didReceiveFrame:(NSData *)frameData{
    
}
@end
