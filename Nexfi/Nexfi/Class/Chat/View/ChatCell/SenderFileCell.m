//
//  SenderFileCell.m
//  Nexfi
//
//  Created by fyc on 16/9/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SenderFileCell.h"

@implementation SenderFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setMsg:(Message *)msg{
    self.currentTime.text = msg.timeStamp;
    TribeMessage *tMsg;
    PersonMessage *pMsg;
    if ([msg isKindOfClass:[TribeMessage class]]) {
        tMsg = (TribeMessage *)msg;
        
        self.fileName.text = tMsg.fileMessage.fileName;
        self.fileSize.text = tMsg.fileMessage.fileSize;
        
    }else{
        pMsg = (PersonMessage *)msg;
        
        self.fileName.text = pMsg.fileMessage.fileName;
        self.fileSize.text = pMsg.fileMessage.fileSize;
        
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
