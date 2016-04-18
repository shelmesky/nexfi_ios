/*
 * Copyright (c) 2016 Vladimir L. Shabanov <virlof@gmail.com>
 *
 * Licensed under the Underdark License, Version 1.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://underdark.io/LICENSE.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "UDChannel.h"

@protocol UDAdapter;

@protocol UDAdapterDelegate <NSObject>

- (void) adapter:(id<UDAdapter>)adapter channelConnected:(id<UDChannel>)channel;
- (void) adapter:(id<UDAdapter>)adapter channelDisconnected:(id<UDChannel>)channel;
- (void) adapter:(id<UDAdapter>)adapter channelCanSendMore:(id<UDChannel>)channel;
- (void) adapter:(id<UDAdapter>)adapter channel:(id<UDChannel>)channel didReceiveFrame:(NSData*)frameData WithProgress:(float)progress;
- (void) adapter:(id<UDAdapter>)adapter channel:(id<UDChannel>)channel didReceiveFrame:(NSData*)frameData;
- (void) adapter:(id<UDAdapter>)adapter channel:(id<UDChannel>)channel fail:(NSString*)fail;

@end

@protocol UDAdapter <NSObject>

@property (nonatomic, readonly) dispatch_queue_t queue;

- (void) start;
- (void) stop;

@end
