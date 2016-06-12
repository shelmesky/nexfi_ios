//
//  MJCommonHeader.m
//  jiaTingXianZhi
//
//  Created by fyc on 16/1/4.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "MJCommonHeader.h"

@implementation MJCommonHeader
- (void)prepare{
    
    [super prepare];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.automaticallyChangeAlpha = YES;
    
    // 设置文字
    [self setTitle:@"下拉可以刷新..." forState:MJRefreshStateIdle];
    [self setTitle:@"松开进行刷新..." forState:MJRefreshStatePulling];
    [self setTitle:@"正在加载数据..." forState:MJRefreshStateRefreshing];
    
    self.lastUpdatedTimeLabel.hidden = YES;
    
    // 设置字体、颜色
    self.stateLabel.font = [UIFont systemFontOfSize:15];
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
