//
//  UITapGestureRecognizer+block.m
//  tapBlock
//
//  Created by fyc on 16/6/27.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UITapGestureRecognizer+block.h"
#import <objc/runtime.h>
static const int target_key;

@implementation UITapGestureRecognizer (block)

+(instancetype)fc_gestureRecognizerWithActionBlock:(FC_GestureBlock)block {
    return [[self alloc]initWithActionBlock:block];
}

- (instancetype)initWithActionBlock:(FC_GestureBlock)block {
    self = [self init];
    [self addActionBlock:block];
    [self addTarget:self action:@selector(invoke:)];
    return self;
}

- (void)addActionBlock:(FC_GestureBlock)block {
    if (block) {
        objc_setAssociatedObject(self, &target_key, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)invoke:(id)sender {
    FC_GestureBlock block = objc_getAssociatedObject(self, &target_key);
    if (block) {
        
        block(sender);
        
    }
}

@end
