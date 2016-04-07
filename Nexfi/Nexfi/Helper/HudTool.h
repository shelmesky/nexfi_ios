//
//  HudTool.h
//  XiaoMu
//
//  Created by ma on 16/2/7.
//  Copyright © 2016年 silvrunrun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JGProgressHUD.h"

@interface HudTool : NSObject
+ (id)showLoadingHudInView:(UIView *)view;
+ (id)showLoadingHudWithText:(NSString *)text inView:(UIView *)view;
+ (id)showErrorHudWithText:(NSString *)text inView:(UIView *)view;
+ (id)showErrorHudWithText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration;
+ (id)showSuccessHudWithText:(NSString *)text inView:(UIView *)view;
+ (id)showSuccessHudWithText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration;
+ (void)dismissHudsInView:(UIView *)view;
@end
