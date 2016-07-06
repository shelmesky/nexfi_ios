//
//  CongureInfoVC.m
//  jiaTingXianZhi
//
//  Created by fyc on 15/12/7.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import "FCCongureInfoVC.h"
#import "UnderdarkUtil.h"

@interface FCCongureInfoVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickName;//用户昵称控件
@end

@implementation FCCongureInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBaseVCAttributesWith:@"个人信息" left:nil right:@"保存" WithInVC:self];
    //获取用户信息
    UserModel *account = [[UserManager shareManager] getUser];
    self.nickName.text = account.userNick;
    self.nickName.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.nickName becomeFirstResponder];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *newString = [[NSMutableString alloc]initWithString:textField.text];
    [newString appendString:string];
    //用户名不能超过20个字符
    if ([NexfiUtil convertToInt:newString] > 20) {
        return NO;
    }
    return YES;
}
- (void)RightBarBtnClick:(id)sender{
    [self.view endEditing:YES];
    
    //修改信息并缓存
    UserModel *account = [[UserManager shareManager] getUser];
    account.userNick = self.nickName.text;
    [[UserManager shareManager] loginSuccessWithUser:account];
    //更新数据库用户数据
    [[SqlManager shareInstance]updateUserName:account];
    //通知好友已经修改信息完毕
    if ([UnderdarkUtil share].node.links.count > 0) {
        for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
            id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
            [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UpdateUserInfo WithLink:myLink]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
