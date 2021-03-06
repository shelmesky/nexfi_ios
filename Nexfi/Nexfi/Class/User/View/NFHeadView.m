//
//  NFHeadView.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//


#import "NFHeadView.h"

@implementation NFHeadView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *headImg = [[UIImageView alloc]initWithFrame:frame];
//        headImg.image = [UIImage imageNamed:@"bg-xxxx@2x"];
        headImg.backgroundColor = [UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha:1];
        headImg.clipsToBounds = YES;
        headImg.userInteractionEnabled = YES;
        headImg.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headImg];
        
        //显示头像控件
        self.userImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_head_01"]];
        self.userImg.bounds = CGRectMake(0, 0, 90, 90);
        self.userImg.userInteractionEnabled = YES;
        self.userImg.clipsToBounds = YES;
        self.userImg.userInteractionEnabled = YES;
        self.userImg.layer.cornerRadius = self.userImg.frame.size.width/2;
        self.userImg.center = CGPointMake((SCREEN_SIZE.width)/2, headImg.frame.size.height/2);
        [headImg addSubview:self.userImg];
        
        //手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [headImg addGestureRecognizer:tap];
        [self setup];
        
    }
    return self;
}
//点击头像事件
- (void)tap:(UITapGestureRecognizer *)tap{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(imgClick:)]) {
        [self.delegate imgClick:tap];
    }
}
- (void)addTribeClick:(id)sender{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(addTribeClicks:)]) {
//        [self.delegate addTribeClicks:sender];
//    }
}
- (void)setup{


}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
