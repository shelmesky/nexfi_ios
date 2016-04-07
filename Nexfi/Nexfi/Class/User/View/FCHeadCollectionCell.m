//
//  FCHeadCollectionCell.m
//  collectionTestVC
//
//  Created by fyc on 15/12/23.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCHeadCollectionCell.h"

@implementation FCHeadCollectionCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.backView.backgroundColor = [UIColor lightGrayColor];
    self.backView.alpha = 0.1;
    [self addSubview:self.backView];
    
}

@end
