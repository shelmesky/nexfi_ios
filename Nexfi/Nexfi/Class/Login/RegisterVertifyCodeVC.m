//
//  RegisterVertifyCodeVC.m
//  Nexfi
//
//  Created by fyc on 16/7/11.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "RegisterVertifyCodeVC.h"
#import "JKCountDownButton.h"
#import "UserInfoVC.h"
#import "RegisterVC.h"
#import "NeighbourVC.h"

//#import <SMS_SDK/SMSSDK.h>
//#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
//#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
//#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
//#import <MOBFoundation/MOBFoundation.h>

@interface RegisterVertifyCodeVC ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *codeInput;
@property (weak, nonatomic) IBOutlet JKCountDownButton *firm;
@property (weak, nonatomic) IBOutlet UIButton *finish;

@end

@implementation RegisterVertifyCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:@"请输入语音验证码" left:nil right:nil WithInVC:self];

    
    [self initView];
    
}
- (void)initView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.phone) {
        self.phoneNum.text = [NSString stringWithFormat:@"+86  %@",self.phone];
    }
    
    //验证码
    self.codeInput.layer.cornerRadius = 5;
    self.codeInput.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.codeInput.layer.borderWidth = 1;
    
    //验证码按钮
    self.firm.layer.cornerRadius = 5;
    //完成
    self.finish.layer.cornerRadius = 5;
    
    //倒计时
    [self codeBtnConfigure];
    

}
//刚进入页面验证码按钮text显示倒计时
- (void)codeBtnConfigure{
    
    self.firm.enabled = NO;
    //button type要 设置成custom 否则会闪动
    [self.firm startWithSecond:60];
    
    [self.firm didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
        return title;
    }];
    [self.firm didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        return @"重新获取";
        
    }];
    
}
- (IBAction)getCodeClick:(id)sender {
    
    UIButton *b = (UIButton*)sender;
    
//    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:self.phone
//                                   zone:@"86"
//                       customIdentifier:nil
//                                 result:^(NSError *error)
//     {
//         if (!error) {
//             NSLog(@"发送成功");
//         }
//     }];
//    
//    b.enabled = NO;
//    //button type要 设置成custom 否则会闪动
//    [sender startWithSecond:60];
//    
//    [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
//        NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
//        return title;
//    }];
//    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
//        countDownButton.enabled = YES;
//        return @"重新获取";
//        
//    }];
    
}
- (IBAction)finishClick:(id)sender {
//    [SMSSDK commitVerificationCode:self.codeInput.text phoneNumber:self.phone zone:@"86" result:^(NSError *error) {
//        if (!error) {
//            NSLog(@"验证成功");
//            NSMutableArray *vcs = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
//            BOOL hasUserInfo = NO;
//            UIViewController *neighbourVC;
//            for (UIViewController *v in vcs) {
//                if ([v isKindOfClass:[NeighbourVC class]]) {//有用户信息 没注册
//                    hasUserInfo = YES;
//                    neighbourVC = v;
//                }
//            }
//            if (hasUserInfo) {//有用户信息 注册成功之后返回到首页
//                UserModel *user = [[UserManager shareManager]getUser];
//                user.phoneNumber = self.phone;
//                [[UserManager shareManager]loginSuccessWithUser:user];
//                [self.navigationController popToViewController:neighbourVC animated:YES];
//            }else{//没有用户信息  注册成功之后去完善用户信息
//                UserModel *user = [[UserManager shareManager]getUser];
//                user.phoneNumber = self.phone;
//                [[UserManager shareManager]loginSuccessWithUser:user];
//                UserInfoVC *vc = [[UserInfoVC alloc]init];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
