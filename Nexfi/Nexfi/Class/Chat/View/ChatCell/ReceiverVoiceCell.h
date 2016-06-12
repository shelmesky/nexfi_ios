//
//  ReceiverVoiceCell.h
//  NexFiSDK
//
//  Created by fyc on 16/5/19.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"
@interface ReceiverVoiceCell : ChatCell

@property (weak, nonatomic) IBOutlet UILabel *voiceSec;
@property (weak, nonatomic) IBOutlet UIImageView *bubble;
@property (weak, nonatomic) IBOutlet UIImageView *voice;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleW;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameConstant;
@property (weak, nonatomic) IBOutlet UIImageView *unReadView;

@property (nonatomic, strong)Message *msg;

//改变录音的播放状态
- (void)sendVoiceMesState:(FNVoiceMessageState)voiceMessageState;
-(void)updateIsRead:(BOOL)isRead;

@end
