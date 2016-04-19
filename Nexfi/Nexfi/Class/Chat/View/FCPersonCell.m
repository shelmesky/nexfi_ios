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
}
- (void)setUser:(UserModel *)user
{
    _user = user;
    if ([self.pTitle.text isEqualToString:@"昵称"]) {
        self.pDsecirp.text = user.userName;
    }
    if ([self.pTitle.text isEqualToString:@"年龄"]) {
        self.pDsecirp.text = user.age;
    }
    if ([self.pTitle.text isEqualToString:@"性别"]) {
        if (user.sex.intValue == 1) {
            self.pDsecirp.text = @"男";
        }else if (user.sex.intValue == 2) {
            self.pDsecirp.text = @"女";
        }else{
            self.pDsecirp.text = @"未设置";
        }
    }
}


@end
