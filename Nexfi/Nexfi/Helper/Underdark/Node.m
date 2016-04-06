//
//  Node.m
//  UnderdarkTest
//
//  Created by fyc on 16/3/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

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
#pragma -mark UDTransportDelegate
- (void)transport:(id<UDTransport>)transport linkConnected:(id<UDLink>)link{
    [self.links addObject:link];
    self.peersCount += 1;
//    [self.controller updatePeerCount];
    self.controller.title = [NSString stringWithFormat:@"%d",self.peersCount];
}
- (void)transport:(id<UDTransport>)transport linkDisconnected:(id<UDLink>)link{
    
    if ([self.links containsObject:link]) {
        [self.links removeObject:link];
    }
    
    self.peersCount -= 1;
//    [self.controller updatePeerCount];
    
}
- (void)transport:(id<UDTransport>)transport link:(id<UDLink>)link didReceiveFrame:(NSData *)frameData{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:frameData options:0 error:0];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"text" object:nil userInfo:@{@"text":dic,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
}

@end
