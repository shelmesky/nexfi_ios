//
//  ChatCell.h
//  NexFiSDK
//
//  Created by fyc on 16/5/19.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
@class ChatCell;
@protocol chatCellDelegate <NSObject>

- (void)clickPic:(NSUInteger)index;//点击聊天图片放大
- (void)clickUserHeadPic:(NSUInteger)index;//点击头像
- (void)msgCellTappedBlank:(ChatCell *)msgCell;//点击空白区域
- (void)msgCellTappedContent:(ChatCell *)msgCell;//点击bubble
//- (void)clickMsgContent:(NSUInteger)index;

@end
#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (nonatomic, assign)id<chatCellDelegate>delegate;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)UserModel *to_user;


@end
