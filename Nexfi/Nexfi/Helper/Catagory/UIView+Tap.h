//
//  UIView+Tap.h
//  ULife
//
//  Created by fengyixiao on 15/8/21.
//  Copyright (c) 2015年 UHouse. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JMWhenTappedBlock)();

@interface UIView (Tap) <UIGestureRecognizerDelegate>
//单击
- (void)whenTapped:(JMWhenTappedBlock)block;
//单击 不影响其他操作;
- (void)whencancelsToucheTapped:(JMWhenTappedBlock)block;

//双击
- (void)whenDoubleTapped:(JMWhenTappedBlock)block;

//双指
- (void)whenTwoFingerTapped:(JMWhenTappedBlock)block;

//按下
- (void)whenTouchedDown:(JMWhenTappedBlock)block;

//弹起
- (void)whenTouchedUp:(JMWhenTappedBlock)block;



@end
