//
//  FCConfigureDateVC.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//
#import "UnderdarkUtil.h"
#import "FCConfigureDateVC.h"
#import "UserManager.h"

@interface FCConfigureDateVC ()
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation FCConfigureDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBaseVCAttributesWith:@"修改生日" left:nil right:@"保存" WithInVC:self];
    //读取缓存生日并显示
    UserModel *user = [[UserManager shareManager] getUser];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthday = [formatter dateFromString:user.birthday];
    
    if (birthday == nil) {
        birthday = [NSDate date];
    }
    
    [self updateLabelsWithDate:birthday];
    self.datePicker.date = birthday;
    self.datePicker.maximumDate = [NSDate date];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)RightBarBtnClick:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:self.datePicker.date];
    
    UserModel *user = [[UserManager shareManager] getUser];
    user.birthday = dateString;
    user.userAge = (int)[self getAgeWithBirthday:self.datePicker.date];
    //更新数据库用户数据
    [[UserManager shareManager]loginSuccessWithUser:user];
    //通知好友已经修改信息完毕
    if ([UnderdarkUtil share].node.links.count > 0) {
        for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
            id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
            [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UpdateUserInfo WithLink:myLink]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//picker值改变事件
- (void)dateChanged:(UIDatePicker *)datePicker{
    NSDate *date = datePicker.date;
    //更新label
    [self updateLabelsWithDate:date];
}

//更新label显示
- (void)updateLabelsWithDate:(NSDate *)date{
    self.ageLabel.text = [NSString stringWithFormat:@"%ld岁",[self getAgeWithBirthday:date]];
    //NSLog(@"相差：%ld年,%ld月,%ld日",cmps.year,cmps.month,cmps.day);
    
}

//根据日期差计算年龄
- (NSInteger)getAgeWithBirthday:(NSDate *)birthday{
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:birthday toDate:[NSDate date] options:0];
    return cmps.year;
}

@end
