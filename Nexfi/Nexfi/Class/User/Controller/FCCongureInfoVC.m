//
//  CongureInfoVC.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCCongureInfoVC.h"
#import "UnderdarkUtil.h"

@interface FCCongureInfoVC ()
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@end

@implementation FCCongureInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBaseVCAttributesWith:@"个人信息" left:nil right:@"保存" WithInVC:self];
    
    UserModel *account = [[UserManager shareManager] getUser];
    self.nickName.text = account.userNick;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.nickName becomeFirstResponder];
}

- (void)RightBarBtnClick:(id)sender{
    [self.view endEditing:YES];
    
    //修改信息并缓存
    UserModel *account = [[UserManager shareManager] getUser];
    account.userNick = self.nickName.text;
    [[UserManager shareManager] loginSuccessWithUser:account];
    //更新数据库用户数据
    [[SqlManager shareInstance]updateUserName:account];
    
    if ([UnderdarkUtil share].node.links.count > 0) {
        for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
            id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
            [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UpdateUserInfo WithLink:myLink]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
