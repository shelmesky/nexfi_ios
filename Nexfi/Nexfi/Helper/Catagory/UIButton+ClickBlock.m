//
//  UIButton+ClickBlock.m
//  tapBlock
//
//  Created by fyc on 16/6/27.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UIButton+ClickBlock.h"
#import <objc/runtime.h>
static const int Target_key;
@implementation UIButton (ClickBlock)

- (void)fc_addTargertActionBlock:(clickBlock)block{
    if (block) {
        objc_setAssociatedObject(self, &Target_key, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self addTarget:self action:@selector(clicks:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)clicks:(id)sender{
    clickBlock block = objc_getAssociatedObject(self, &Target_key);
    if (block) {
        block(sender);
    }
}

@end
