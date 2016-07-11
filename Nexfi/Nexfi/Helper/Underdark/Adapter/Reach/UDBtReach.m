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

#import "UDBtReach.h"

@import CoreBluetooth;

#import "UDLogging.h"
#import "UDAsyncUtils.h"

@interface UDBtReach() <CBCentralManagerDelegate>
{
	__weak id<UDReachDelegate> _delegate;
	bool _running;
	
	CBCentralManager* _manager;
	dispatch_queue_t _queue;
	bool _reachable;
}
@end

@implementation UDBtReach

- (instancetype)initWithDelegate:(id<UDReachDelegate>)delegate queue:(dispatch_queue_t)queue
{
	if(!(self = [super init]))
		return self;
	
	_delegate = delegate;
	_queue = queue;
	
	return self;
}

- (void) start
{
	if(_running)
		return;
	
	_running = true;
	
#if TARGET_IPHONE_SIMULATOR
	sldispatch_async(_queue, ^{
		_reachable = true;
		[_delegate ifaceBecomeReachable:self];
	});
#else
	NSDictionary* options = @{CBCentralManagerOptionShowPowerAlertKey:@(NO)};
	_manager = [[CBCentralManager alloc] initWithDelegate:self queue:_queue options:options];
#endif
}

- (void) stop
{
	if(!_running)
		return;
	
	_running = true;
	
	_manager.delegate = nil;
	_manager = nil;
	_reachable = false;
}

- (bool) isReachable
{
	return _reachable;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	CBCentralManagerState state = central.state;
    
    if (state == 2 || state == 3 || state == 4) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"blueToothFail" object:nil];
    }
	
	if(state == CBCentralManagerStateUnknown)//初始化
	{
		//LogDebug(@"bt-reach CBCentralManagerStateUnknown");
		if(_reachable)
		{
			_reachable = false;
			[_delegate ifaceBecomeUnreachable:self];
		}
	}
	
	if(state == CBCentralManagerStateResetting) //设备不支持状态，重置
	{
		//LogDebug(@"bt-reach CBCentralManagerStateResetting");
		if(_reachable)
		{
			_reachable = false;
			[_delegate ifaceBecomeUnreachable:self];
		}
	}

	if(state == CBCentralManagerStateUnsupported)//不支持
	{
		//LogDebug(@"bt-reach CBCentralManagerStateUnsupported");
		if(_reachable)
		{
			_reachable = false;
			[_delegate ifaceBecomeUnreachable:self];
		}
	}

	if(state == CBCentralManagerStateUnauthorized)//未授权
	{
		//LogDebug(@"bt-reach CBCentralManagerStateUnauthorized");
		if(_reachable)
		{
			_reachable = false;
			[_delegate ifaceBecomeUnreachable:self];
		}
	}

	if(state == CBCentralManagerStatePoweredOff)//尚未打开蓝牙
	{
		//LogDebug(@"bt-reach CBCentralManagerStatePoweredOff");
		if(_reachable)
		{
			_reachable = false;
			[_delegate ifaceBecomeUnreachable:self];
		}
	}

	if(state == CBCentralManagerStatePoweredOn)//蓝牙开启
	{
		//LogDebug(@"bt-reach CBCentralManagerStatePoweredOn");
		if(!_reachable)
		{
			_reachable = true;
			[_delegate ifaceBecomeReachable:self];
		}
	}
} // centralManagerDidUpdateState
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
}

@end
