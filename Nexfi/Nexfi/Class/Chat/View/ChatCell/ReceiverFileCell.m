//
//  ReceiverFileCell.m
//  Nexfi
//
//  Created by fyc on 16/9/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ReceiverFileCell.h"

@implementation ReceiverFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setMsg:(Message *)msg{
    _msg = msg;
    self.currentTime.text = msg.timeStamp;
    TribeMessage *tMsg;
    PersonMessage *pMsg;
    NSString *type;
    if ([msg isKindOfClass:[TribeMessage class]]) {
        tMsg = (TribeMessage *)msg;
        
        self.fileName.text = tMsg.fileMessage.fileName;
        self.fileSize.text = [NSString stringWithFormat:@"%@k",tMsg.fileMessage.fileSize];
        NSString *pathExtation = [[tMsg.fileMessage.fileName componentsSeparatedByString:@"."] lastObject];
        //归类 比如文档 音频 视频
        type = [NexfiUtil getFileTypeWithFileSuffix:pathExtation];
        
        
    }else{
        pMsg = (PersonMessage *)msg;
        
        self.fileName.text = pMsg.fileMessage.fileName;
        self.fileSize.text = [NSString stringWithFormat:@"%@k",pMsg.fileMessage.fileSize];
        NSString *pathExtation = [[pMsg.fileMessage.fileName componentsSeparatedByString:@"."] lastObject];
        //归类 比如文档 音频 视频
        type = [NexfiUtil getFileTypeWithFileSuffix:pathExtation];
        
    }
    NSString *imageName;
    if ([type isEqualToString:@"文档"]) {
        imageName = @"wenjian";
    }else if ([type isEqualToString:@"音频"]){
        imageName = @"yinpin";
    }else{//视频
        imageName = @"shipin";
    }
    self.fileTypeImage.image = [UIImage imageNamed:imageName];
    
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
            }else if (self.msg.messageBodyType == eMessageBodyType_File){
                if (self.delegate && [self.delegate respondsToSelector:@selector(msgCellTappedContentWithFile:)]) {
                    [self.delegate msgCellTappedContentWithFile:self];
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
