//
//  NFTribeInfoCell.m
//  Nexfi
//
//  Created by fyc on 16/4/14.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFTribeInfoCell.h"

@implementation NFTribeInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height - 1, SCREEN_SIZE.width - 10, 1)];
    line.backgroundColor = [UIColor colorWithRed:78.43/255.0 green:71.18/255.0 blue:76.80/255.0 alpha:0.3];
    [self addSubview:line];
}
- (void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    
//    NSData *headData = [[NSData alloc]initWithBase64EncodedString:userModel.headImgStr];
    
    self.HeadImg.image = [UIImage imageNamed:userModel.headImgPath];
    self.nameLa.text = userModel.userName;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
