//
//  BackGroundTask.h
//  Nexfi
//
//  Created by fyc on 16/8/9.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BackGroundTask : NSObject

+(instancetype)shareBGTask;
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask; //开启后台任务

@end
