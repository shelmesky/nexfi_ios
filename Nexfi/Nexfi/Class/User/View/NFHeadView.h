//
//  NFHeadView.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NFHeadViewDelegate <NSObject>

- (void)refeshHeightOfHeadView:(CGFloat)height; //刷新collection的高度
- (void)addTribeClicks:(id)sender;  //加入群聊
- (void)imgClick:(id)sender;  //点击图片

@end
@interface NFHeadView : UIView

@property (nonatomic,assign)id<NFHeadViewDelegate>delegate;
@property (nonatomic,strong)UIImageView *userImg;


@end
