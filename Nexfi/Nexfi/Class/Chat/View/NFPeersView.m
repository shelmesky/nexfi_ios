//
//  NFPeersView.m
//  Nexfi
//
//  Created by fyc on 16/4/13.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFPeersView.h"

@implementation NFPeersView
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
- (void)setUp{
    self.peesCount  = [[UILabel alloc]init];
    self.peesCount.center = CGPointMake(SCREEN_SIZE.width/2, 15);
    self.peesCount.bounds = CGRectMake(0, 0, 100, 30);
    self.peesCount.font = [UIFont systemFontOfSize:15.0];
    self.peesCount.textAlignment = NSTextAlignmentCenter;
    self.peesCount.text = @"无人响应...";
    [self addSubview:self.peesCount];
    
    self.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
