//
//  NexfiUtil.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
//#import "UnderdarkUtil.h"
#import "Message.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>


#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>

@interface NexfiUtil : NSObject

-(NSString *)switchDate:(NSString *)date returnType:(NSUInteger)type;

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。

+(NSDictionary*)getObjectData:(id)obj;

//将getObjectData方法返回的NSDictionary转化成JSON

+(NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;

//直接通过NSLog输出getObjectData方法返回的NSDictionary

+(void)print:(id)obj;

+ (NSString*) uuid ;
+ (instancetype)shareUtil;
//布局tabbar
- (void)layOutTheApp;
- (void)configureTabVC;

+(BOOL)isMeSend:(Message *)msg;
/**
 *计算字体个数
 */
+(int)convertToInt:(NSString*)strtemp;
//验证短信
+ (BOOL)getVerificationCodeByMethod:(SMSGetCodeMethod)getCodeMethod phoneNumber:(NSString *)phoneNumber zone:(NSString *)zone;

//-(void)toUpdateUserInfo;
@end
