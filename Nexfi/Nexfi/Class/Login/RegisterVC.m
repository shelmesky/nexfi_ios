//
//  RegisterVC.m
//  Nexfi
//
//  Created by fyc on 16/7/11.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "RegisterVC.h"
#import "RegisterVertifyCodeVC.h"

//#import <SMS_SDK/SMSSDK.h>
//#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
//#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
//#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
//#import <MOBFoundation/MOBFoundation.h>

@interface RegisterVC ()
@property (weak, nonatomic) IBOutlet LooseTextField *phoneTe;
@property (weak, nonatomic) IBOutlet UIButton *getCode;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBaseVCAttributesWith:@"注册" left:nil right:nil WithInVC:self];

    self.icon.layer.cornerRadius = 5;
    
    self.phoneTe.layer.cornerRadius = 5;
    self.phoneTe.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneTe.layer.borderWidth = 1;
    
    self.getCode.layer.cornerRadius = 5;
    
}
//判断是否是手机号
- (BOOL)isPhoneNumber{
    NSString *rule = @"^1(3|5|7|8|4)\\d{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule];
    BOOL isPhoneNumber = [pred evaluateWithObject:self.phoneTe.text];
    
    return isPhoneNumber;
}
- (IBAction)getCodeClick:(id)sender {
    
//    if ([self isPhoneNumber]) {
//    
//        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:self.phoneTe.text
//                                       zone:@"86"
//                           customIdentifier:nil
//                                     result:^(NSError *error)
//         {
//             if (!error) {
//                 NSLog(@"语音短信验证码发送成功");
//                 RegisterVertifyCodeVC *vertifyCodeVc = [[RegisterVertifyCodeVC alloc]init];
//                 vertifyCodeVc.phone = self.phoneTe.text;
//                 [self.navigationController pushViewController:vertifyCodeVc animated:YES];
//             }
//             
//         }];
//
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无效手机号" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        
//    }
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 //手机号码判断
 - (BOOL) isValidateMobile:(NSString *)mobile
 {
 //手机号以13， 15，18开头，八个 \d 数字字符
 NSString *phoneRegex = @"^1[3-9]\\d{9}$";
 NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
 //固话不加区号的
 NSString * CT1 = @"^(0[0-9]{2,3}/-)?([2-9][0-9]{6,7})+(/-[0-9]{1,4})?$";
 NSPredicate *regextestct1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT1];
 //固话加区号的
 NSString * CT2 = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
 NSPredicate *regextestct2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT2];
 
 if ([phoneTest evaluateWithObject:mobile] || [regextestct1 evaluateWithObject:mobile] || [regextestct2 evaluateWithObject:mobile])
 {
 return YES;
 }
 else
 {
 return NO;
 }
 }
 */
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
