//
//  CongureInfoVC.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCCongureInfoVC.h"


@interface FCCongureInfoVC ()
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@end

@implementation FCCongureInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBaseVCAttributesWith:@"个人信息" left:nil right:@"保存" WithInVC:self];
    
    UserModel *account = [[UserManager shareManager] getUser];
    self.nickName.text = account.userName;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.nickName becomeFirstResponder];
}

- (void)RightBarBtnClick:(id)sender{
    [self.view endEditing:YES];

    //修改信息并缓存
    UserModel *account = [[UserManager shareManager] getUser];
    account.userName = self.nickName.text;
    [[UserManager shareManager] loginSuccessWithUser:account];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end