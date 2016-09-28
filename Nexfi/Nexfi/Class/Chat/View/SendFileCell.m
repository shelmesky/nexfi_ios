//
//  SendFileCell.m
//  Nexfi
//
//  Created by fyc on 16/9/28.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SendFileCell.h"

@implementation SendFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.fileNameLa.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
