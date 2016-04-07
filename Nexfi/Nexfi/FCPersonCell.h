//
//  PersonInfoCell.h
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface FCPersonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pTitle;
@property (nonatomic,strong) UserModel *user;

@end
