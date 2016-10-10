//
//  PersonInfoCell.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCPersonCell.h"
#import "UserManager.h"
@interface FCPersonCell ()
@property (weak, nonatomic) IBOutlet UILabel *pDsecirp;
@end

@implementation FCPersonCell
- (void)awakeFromNib{
    self.pDsecirp.adjustsFontSizeToFitWidth = YES;
    
    [super awakeFromNib];
}
- (void)setUser:(UserModel *)user
{
    _user = user;
    
    if (![_user.userId isEqualToString:[[UserManager shareManager]getUser].userId]) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([self.pTitle.text isEqualToString:@"昵称"]) {
        self.pDsecirp.text = user.userNick;
    }
    if ([self.pTitle.text isEqualToString:@"年龄"]) {
        self.pDsecirp.text = [NSString stringWithFormat:@"%d",user.userAge];
    }
    if ([self.pTitle.text isEqualToString:@"性别"]) {
        if (user.userGender.intValue == 1) {
            self.pDsecirp.text = @"男";
        }else if (user.userGender.intValue == 2) {
            self.pDsecirp.text = @"女";
        }else{
            self.pDsecirp.text = @"";
        }
    }
    
}


@end
