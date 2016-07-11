//
//  UIButton+ClickBlock.h
//  tapBlock
//
//  Created by fyc on 16/6/27.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
typedef void(^clickBlock)(id sender);
#import <UIKit/UIKit.h>

@interface UIButton (ClickBlock)

- (void)fc_addTargertActionBlock:(clickBlock)block;

@end
