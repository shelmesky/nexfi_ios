//
//  PersonHeadCell.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCPersonHeadCell.h"

@implementation FCPersonHeadCell

- (void)awakeFromNib {
    self.pHead.clipsToBounds = YES;
    self.pHead.layer.cornerRadius = self.pHead.frame.size.height/2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
