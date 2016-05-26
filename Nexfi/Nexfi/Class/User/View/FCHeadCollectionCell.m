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
    
    self.backView = [[UIImageView alloc]init];
    self.backView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.backView.bounds = CGRectMake(0, 0, 30, 30);
    self.backView.image = [UIImage imageNamed:@"check34"];
//    self.backView.alpha = 0.1;
    [self addSubview:self.backView];
    
}

@end
