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
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderIconView;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameWidth;

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
    if (user.headImg) {
        
//        self.headImageView.image = [UIImage imageWithData:(NSData *)user.headImg];
        NSLog(@"---===%@",(NSData *)user.headImg);
        user.userHead = [user.headImg dataUsingEncoding:NSUTF8StringEncoding];
        user.headImg = nil;
        [[UserManager shareManager]loginSuccessWithUser:user];
        
    }else if (user.userHead){
        self.headImageView.image = [UIImage imageWithData:user.userHead];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"img_head_01"];
    }
    
    self.nickNameLabel.text = user.userName;

    CGSize labels = [self.nickNameLabel.text sizeWithAttributes:@{NSFontAttributeName:self.nickNameLabel.font}];
    self.nickNameWidth.constant = labels.width;
    
    
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
