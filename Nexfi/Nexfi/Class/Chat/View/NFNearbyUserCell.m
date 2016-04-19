//
//  FCNearbyUserCell.m
//  jiaTingXianZhi
//
//  Created by ma on 15/12/30.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "NFNearbyUserCell.h"
#import "UserModel.h"
#import "UserManager.h"

@interface NFNearbyUserCell ()


@end


@implementation NFNearbyUserCell

- (void)awakeFromNib {
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width/2.0;
    self.headImageView.clipsToBounds = YES;
    
    self.chatButton.layer.cornerRadius = 5;
    self.chatButton.clipsToBounds = YES;
}

- (void)setUser:(UserModel *)user{
    _user = user;
//    if (user.headImgStr || [user.headImgStr isKindOfClass:[NSNull class]]) {
//        
//        NSData *data = [[NSData alloc]initWithBase64EncodedString:user.headImgStr];
//        self.headImageView.image = [UIImage imageWithData:data];
//        
//    }
    if (user.headImgPath) {
        self.headImageView.image = [UIImage imageNamed:user.headImgPath];
    }
    else{
        self.headImageView.image = [UIImage imageNamed:@"img_head_01"];
    }
    
    self.nickNameLabel.text = user.userName;

    CGSize labels = [self.nickNameLabel.text sizeWithAttributes:@{NSFontAttributeName:self.nickNameLabel.font}];
    self.nickNameWidth.constant = labels.width + 1;
    
    
    //男女icon(1男2女)
    if ([[NSString stringWithFormat:@"%@",user.sex] isEqualToString:@"1"]) {
        self.genderIconView.image = [UIImage imageNamed:@"054"];
        self.genderIconView.hidden = NO;
    }else if ([[NSString stringWithFormat:@"%@",user.sex] isEqualToString:@"2"]){
        self.genderIconView.image = [UIImage imageNamed:@"057"];
        self.genderIconView.hidden = NO;
    }else{
        self.genderIconView.hidden = YES;
    }
}

- (IBAction)chatButtonClicked {
    if ([self.delegate respondsToSelector:@selector(nearbyUserCellDidClickChatButtonForIndexPath:)]) {
        [self.delegate nearbyUserCellDidClickChatButtonForIndexPath:self.indexPath];
    }
}

@end
