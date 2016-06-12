//
//  NFTribeInfoCell.h
//  Nexfi
//
//  Created by fyc on 16/4/14.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UserModel.h"
#import <UIKit/UIKit.h>

@interface NFTribeInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *HeadImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLa;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameW;

@property (nonatomic,retain)UserModel *userModel;

@end
