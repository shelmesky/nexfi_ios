//
//  SenderTextCell.m
//  NexFiSDK
//
//  Created by fyc on 16/5/18.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SenderTextCell.h"

@implementation SenderTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setMsg:(Message *)msg{
    
    self.currentTime.text = msg.timeStamp;
    _msg = msg;

    NSString *content;
    if ([msg isKindOfClass:[TribeMessage class]]) {
        TribeMessage *Msg = (TribeMessage *)msg;
        content = Msg.textMessage.fileData;
    }else{
        PersonMessage *Msg = (PersonMessage *)msg;
        content = Msg.textMessage.fileData;
    }
    self.msgContent.text = content;
    CGRect textSize = [content boundingRectWithSize:CGSizeMake(200, 10000) options:
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine|
                       NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:0];

    self.msgContentH.constant = textSize.size.height > 30?textSize.size.height + 10:30;
    self.msgContentW.constant = textSize.size.width + 10;
    
    
//    [self setNeedsLayout];
    
}
- (IBAction)tapText:(id)sender {
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
