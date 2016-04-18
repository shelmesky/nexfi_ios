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

@class JXEmoji;
@class JXImageView;
//头像大小
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
//间距
#define INSETS 8.0f

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
}

@property (nonatomic) int index;
@property (nonatomic, assign) Message * msg;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;

/**
 *  显示消息发送状态的UIImageView -> 用于消息发送不成功时显示
 */
@property (nonatomic, strong) FNSendImageView *messageSendStateIV;
/**
 *  消息发送状态,当状态为XMNMessageSendFail或XMNMessageSendStateSending时,XMNMessageSendStateIV显示
 */
@property (nonatomic, assign) FNMessageSendState messageSendState;

-(void)setHeadImage:(UIImage*)headImage;
-(void)setHeadImageWithURL:(NSURL*) imgUrl;
-(BOOL)isMeSend;
-(void)updateIsRead:(BOOL)b;

@end
