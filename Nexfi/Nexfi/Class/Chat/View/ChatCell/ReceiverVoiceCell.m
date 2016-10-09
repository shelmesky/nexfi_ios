//
//  ReceiverVoiceCell.m
//  NexFiSDK
//
//  Created by fyc on 16/5/19.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ReceiverVoiceCell.h"

@implementation ReceiverVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImage *image1 = [UIImage imageNamed:@"message_voice_receiver_playing_1"];
    UIImage *image2 = [UIImage imageNamed:@"message_voice_receiver_playing_2"];
    UIImage *image3 = [UIImage imageNamed:@"message_voice_receiver_playing_3"];
    self.voice.animationImages = @[image1,image2,image3];
    self.voice.animationDuration = 1;
}
- (void)sendVoiceMesState:(FNVoiceMessageState)voiceMessageState{
    if (voiceMessageState == FNVoiceMessageStateNormal) {
        //        self.messageVoiceStatusIV.hidden = YES;
        [self.voice stopAnimating];
    }else if (voiceMessageState == FNVoiceMessageStatePlaying){
        //        self.messageVoiceStatusIV.hidden = NO;
        [self.voice startAnimating];
    }else if (voiceMessageState == FNVoiceMessageStateCancel){
        //        self.messageVoiceStatusIV.hidden = YES;
        [self.voice stopAnimating];
    }
}
- (IBAction)tapVoice:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.bubble.frame, tapPoint)) {//点击bubble
            if (self.msg.messageBodyType == eMessageBodyType_Voice) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(msgCellTappedContent:)]) {
                    [self.delegate msgCellTappedContent:self];
                }
            }
        }else if (CGRectContainsPoint(self.avatar.frame, tapPoint)){//点击头像

        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgCellTappedBlank:)]) {
                [self.delegate msgCellTappedBlank:self];
            }
        }
    }
}
- (void)setMsg:(Message *)msg{
    
    self.currentTime.text = msg.timeStamp;
    
    _msg = msg;
    NSString *content;
    NSString *durational;
    NSString *nickName;
    NSString *isRead;
    if ([msg isKindOfClass:[TribeMessage class]]) {
        TribeMessage *Msg = (TribeMessage *)msg;
        content = Msg.voiceMessage.fileData;
        durational = Msg.voiceMessage.durational;
        nickName = Msg.userMessage.userNick;
        isRead = Msg.voiceMessage.isRead;
    }else{
        PersonMessage *Msg = (PersonMessage *)msg;
        content = Msg.voiceMessage.fileData;
        durational = Msg.voiceMessage.durational;
        isRead = Msg.voiceMessage.isRead;

    }
    if (self.to_user) {
        nickName = self.to_user.userNick;
    }
    
    self.voiceSec.text = [NSString stringWithFormat:@"%@'",durational];
    self.voiceSec.adjustsFontSizeToFitWidth = YES;
    
    //根据总时间计算bubble的宽度
    //50 头像宽度  82 bubble宽度
    float bubbleTotalW  = SCREEN_SIZE.width - (2*10 + 50 + 20)*2;//bubble最大宽度
    float perSecWidth = (float)(bubbleTotalW - 82)/60;//没秒bubble增大的宽度
    
    
    CGFloat BubbleEndW = ([durational intValue] - 3)*perSecWidth + 82; //大于3的bubble的长度
//    CGFloat BubbleOrX = SCREEN_SIZE.width-BubbleEndW-self.avatar.width-10*2;
    
    self.bubbleW.constant = BubbleEndW;
    
    //姓名
    self.nickName.text = nickName;
    CGSize size = [self.nickName.text sizeWithAttributes:@{NSFontAttributeName:self.nickName.font}];
    self.nickNameConstant.constant = size.width + 10;
    
    [isRead isEqualToString:@"1"]?[self updateIsRead:YES]:[self updateIsRead:NO];
    
}
-(void)updateIsRead:(BOOL)isRead{
    if (isRead) {
        self.unReadView.hidden = YES;
    }else{
        self.unReadView.hidden = NO;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
