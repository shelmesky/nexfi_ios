//
//  ReceiverAvatarCell.m
//  NexFiSDK
//
//  Created by fyc on 16/5/18.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ReceiverAvatarCell.h"

@implementation ReceiverAvatarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setMsg:(Message *)msg{
    
    self.currentTime.text = msg.timeStamp;
    _msg = msg;

    NSString *content;
    NSString *nickName;
    if ([msg isKindOfClass:[TribeMessage class]]) {
        TribeMessage *Msg = (TribeMessage *)msg;
        content = Msg.fileMessage.fileData;
        nickName = Msg.userMessage.userNick;
    }else{
        PersonMessage *Msg = (PersonMessage *)msg;
        content = Msg.fileMessage.fileData;
    }
    if (self.to_user) {
        nickName = self.to_user.userNick;
    }
    

    //聊天图片
    NSData *picData = [[NSData alloc]initWithBase64EncodedString:content];
    self.chatPic.image = [[UIImage alloc]initWithData:picData];
    
    self.chatPicH.constant = (float)(78*self.chatPic.image.size.height)/(float)self.chatPic.image.size.width;
    
    //姓名
    self.nickName.text = nickName;
    CGSize size = [self.nickName.text sizeWithAttributes:@{NSFontAttributeName:self.nickName.font}];
    self.nickNameConstant.constant = size.width + 10;
    
}
- (IBAction)tapChatImg:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.chatPic.frame, tapPoint)){//点击图片
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPic:)]) {
                [self.delegate clickPic:self.index];
            }
        }else if(CGRectContainsPoint(self.avatar.frame, tapPoint)){//点击头像
            
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgCellTappedBlank:)]) {
                [self.delegate msgCellTappedBlank:self];
            }
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
