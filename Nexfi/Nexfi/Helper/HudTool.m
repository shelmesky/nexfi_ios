//
//  HudTool.m
//  XiaoMu
//
//  Created by ma on 16/2/7.
//  Copyright © 2016年 silvrunrun. All rights reserved.
//

#import "HudTool.h"

#define kDefaultDuration 1

@implementation HudTool
+ (id)showLoadingHudInView:(UIView *)view{
    return [self showLoadingHudWithText:@"" inView:view];
}

+ (id)showLoadingHudWithText:(NSString *)text inView:(UIView *)view{
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    [hud dismissAfterDelay:2];
    if (text.length) {
        hud.textLabel.text = text;
    }
    [hud showInView:view];
    return hud;
}

+ (id)showErrorHudWithText:(NSString *)text inView:(UIView *)view{
    return [self showErrorHudWithText:text inView:view duration:kDefaultDuration];
}

+ (id)showErrorHudWithText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration{
    JGProgressHUD *errorHud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    errorHud.textLabel.text = text;
    errorHud.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    errorHud.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    [errorHud showInView:view];
    [errorHud dismissAfterDelay:duration];
    return errorHud;
}

+ (id)showSuccessHudWithText:(NSString *)text inView:(UIView *)view{
    return [self showSuccessHudWithText:text inView:view duration:kDefaultDuration];
}

+ (id)showSuccessHudWithText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration{
    JGProgressHUD *successHud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    successHud.textLabel.text = text;
    successHud.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    successHud.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    [successHud showInView:view];
    [successHud dismissAfterDelay:duration];
    return successHud;
}

+ (void)dismissHudsInView:(UIView *)view{
    NSArray *huds = [JGProgressHUD allProgressHUDsInView:view];
    for (JGProgressHUD *hud in huds) {
        [hud dismissAnimated:YES];
    }
}
@end
