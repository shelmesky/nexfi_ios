//
//  UITapGestureRecognizer+block.h
//  tapBlock
//
//  Created by fyc on 16/6/27.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
typedef void(^FC_GestureBlock)(id gestureRecognizer);
#import <UIKit/UIKit.h>

@interface UITapGestureRecognizer (block)

+(instancetype)fc_gestureRecognizerWithActionBlock:(FC_GestureBlock)block;

@end
