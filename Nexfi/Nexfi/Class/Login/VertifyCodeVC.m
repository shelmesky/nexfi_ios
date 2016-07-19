//
//  VertifyCodeVC.m
//  Nexfi
//
//  Created by fyc on 16/7/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "VertifyCodeVC.h"
#import "RegisterVertifyCodeVC.h"

//#import <SMS_SDK/SMSSDK.h>
//#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
//#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
//#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
//#import <MOBFoundation/MOBFoundation.h>

@interface VertifyCodeVC ()
@property (weak, nonatomic) IBOutlet LooseTextField *phoneTe;
@property (weak, nonatomic) IBOutlet UIButton *sendCode;

@end

@implementation VertifyCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:@"注册NexFi" left:nil right:nil WithInVC:self];
    
    self.sendCode.layer.cornerRadius = 5;
    
}
//判断是否是手机号
- (BOOL)isPhoneNumber{
    NSString *rule = @"^1(3|5|7|8|4)\\d{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule];
    BOOL isPhoneNumber = [pred evaluateWithObject:self.phoneTe.text];
    
    return isPhoneNumber;
}
- (IBAction)sendCodeClick:(id)sender {
    
//     if ([self isPhoneNumber]) {
//     
//     [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:self.phoneTe.text
//     zone:@"86"
//     customIdentifier:nil
//     result:^(NSError *error)
//     {
//     if (!error) {
//     NSLog(@"语音短信验证码发送成功");
//     RegisterVertifyCodeVC *vertifyCodeVc = [[RegisterVertifyCodeVC alloc]init];
//     vertifyCodeVc.phone = self.phoneTe.text;
//     [self.navigationController pushViewController:vertifyCodeVc animated:YES];
//     }
//     
//     }];
//     
//     }else{
//     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无效手机号" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//     [alert show];
//     
//     }
    
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
