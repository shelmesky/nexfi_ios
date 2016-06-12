//
//  FCMsgCell.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "TribeMessage.h"
#import "PersonMessage.h"
#import "FNSendImageView.h"
#import "JXEmoji.h"
#import "JXImageView.h"
//头像大小
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
//间距
#define INSETS 8.0f



@class FCMsgCell;
@protocol FCMsgCellDelegate <NSObject>

- (void)clickPic:(NSUInteger)index;//点击聊天图片放大
- (void)clickUserHeadPic:(NSUInteger)index;//点击头像
- (void)msgCellTappedBlank:(FCMsgCell *)msgCell;//点击空白区域
- (void)msgCellTappedContent:(FCMsgCell *)msgCell;//点击bubble
//- (void)clickMsgContent:(NSUInteger)index;

@end

@interface FCMsgCell : UITableViewCell

{
    JXImageView *_userHead;
    UIButton *_bubbleBg;
    JXImageView *_headMask;
    JXImageView *_chatImage;
    JXImageView *_readImage;
    JXEmoji *_messageConent;
    UILabel* _timeLabel;
    BOOL _drawed;
    UILabel *_nickName;
    UILabel *_durationLa;
    JXEmoji *_voiceContent;
}
@property (nonatomic, assign)id<FCMsgCellDelegate>msgDelegate;
@property (nonatomic) int index;
@property (nonatomic, assign) Message * msg;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) int cellHeight;
@property (nonatomic, retain) UserModel *to_User;


/**
 *  显示消息发送状态的UIImageView -> 用于消息发送不成功时显示
 */
@property (nonatomic, strong) FNSendImageView *messageSendStateIV;
/**
 *  消息发送状态,当状态为XMNMessageSendFail或XMNMessageSendStateSending时,XMNMessageSendStateIV显示
 */
@property (nonatomic, assign) FNMessageSendState messageSendState;

@property (nonatomic, assign) FNVoiceMessageState voiceMessageState;

@property (nonatomic, retain) UIImageView *messageVoiceStatusIV;

-(void)setHeadImage:(UIImage*)headImage;
//-(void)setHeadImageWithURL:(NSURL*) imgUrl;
//是不是本人
-(BOOL)isMeSend;
//更新为已读状态
-(void)updateIsRead:(BOOL)b;
//改变录音的播放状态
- (void)sendVoiceMesState:(FNVoiceMessageState)voiceMessageState;

@end
