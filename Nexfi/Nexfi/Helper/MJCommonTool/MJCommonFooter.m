//
//  MJCommonFooter.m
//  jiaTingXianZhi
//
//  Created by fyc on 16/1/4.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "MJCommonFooter.h"

@implementation MJCommonFooter
- (void)prepare{
    
    [super prepare];
    
    // 禁止自动加载
    self.automaticallyRefresh = YES;
    
    // 设置文字
    [self setTitle:@"点击或上拉加载更多..." forState:MJRefreshStateIdle];
    [self setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    [self setTitle:@"没有更多数据了..." forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    self.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    self.stateLabel.textColor = [UIColor darkGrayColor];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
