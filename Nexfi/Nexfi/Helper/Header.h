//
//  Header.h
//  chaqianma
//
//  Created by foc on 15/9/2.
//  Copyright (c) 2015年 foc. All rights reserved.
//

#ifndef chaqianma_Header_h
#define chaqianma_Header_h

#import "Underdark.h"
#import "StringHelper.h"
#import "ConFunc.h"
#import "UserModel.h"
#import "HudTool.h"
#import "NexfiUtil.h"
#import "UserManager.h"
#import "NSDataEx.h"
#import "SqlManager.h"
#import "UIColor+Hex.h"
#import "WGradientProgress.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "ConFunc.h"
#import "IQKeyboardManager.h"
#import "FNAVAudioPlayer.h"
#import "XMNChat.h"
#import "MJExtension.h"
#import "TextMessage.h"
#import "FileMessage.h"
#import "VoiceMessage.h"
#import "UIView+Frame.h"
#import "MJCommonHeader.h"
#import "MJCommonFooter.h"
#import "LooseTextField.h"
#import "UITapGestureRecognizer+block.h"
#import "UIButton+ClickBlock.h"
#import "Reachability.h"
#import "KxMenu.h"
#import "UIView+Tap.h"
#import "LPActionSheet.h"
#import "NSFileManager+Handle.h"
#import "ForwardAlert.h"

#import "Message.h"

//#import "CoreJPush.h"
#define UmengAppKey @"55eea2a767e58e4d04001045"

#define WXAPPID @"wxea959f5083eb7caa"
#define WXAPPsecret @"b521fed115fcf66f8d9940968b2cdb62"

#define GAODEAPIKEY @"ee66d7ef352d7b35d2a19997fa3aadb2"
#define WXUrl @"http://sns.whalecloud.com/sina2/callback"

#define myDotNumbers     @"0123456789.\n"   //匹配金额
#define myNumbers          @"0123456789\n"  //匹配数字

//判断设备为4寸屏幕
#define RETINA_4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)



#define USER_D [NSUserDefaults standardUserDefaults]


//判断iphone 4s
#define isIphone4s ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height < 481.0f)
//5
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)
//6
#define IS_IPhone6 (667 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)
//6p
#define IS_IPhone6plus (736 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)

//判断ios7
#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define IPHONE4 ([[[UIDeviceHardware share]deviceName]isEqualToString:@"iPhone 4"])

//当前屏幕大小
#define SCREEN_SIZE   [[UIScreen mainScreen] bounds].size

#define CLIENT_VERSION [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleVersion"]

/**
 *	获取视图宽度
 *
 *	@param 	view 	视图对象
 *
 *	@return	宽度
 */
#define DEF_WIDTH(view) view.bounds.size.width

/**
 *	获取视图高度
 *
 *	@param 	view 	视图对象
 *
 *	@return	高度
 */
#define DEF_HEIGHT(view) view.bounds.size.height

/**
 *	获取视图原点横坐标
 *
 *	@param 	view 	视图对象
 *
 *	@return	原点横坐标
 */
#define DEF_LEFT(view) view.frame.origin.x

/**
 *	获取视图原点纵坐标
 *
 *	@param 	view 	视图对象
 *
 *	@return	原点纵坐标
 */
#define DEF_TOP(view) view.frame.origin.y

/**
 *	获取视图右下角横坐标
 *
 *	@param 	view 	视图对象
 *
 *	@return	右下角横坐标
 */
#define DEF_RIGHT(view) (DEF_LEFT(view) + DEF_WIDTH(view))

/**
 *	获取视图右下角纵坐标
 *
 *	@param 	view 	视图对象
 *
 *	@return	右下角纵坐标
 */
#define DEF_BOTTOM(view) (DEF_TOP(view) + DEF_HEIGHT(view))

/**
 *  主屏的宽
 */
#define DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

/**
 *  主屏的高
 */
#define DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

/**
 *  主屏的size
 */
#define DEF_SCREEN_SIZE   [[UIScreen mainScreen] bounds].size

/**
 *  主屏的frame
 */
#define DEF_SCREEN_FRAME  [UIScreen mainScreen].applicationFrame

// 颜色(RGB)
#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


/**
 *	生成二进制颜色
 *
 *	@param 	hex 	颜色描述字符串，带“0x”开头
 *
 *	@return	UIColor对象
 */
#define DEF_HEX_COLOR(hex)          [UIColor colorWithRGBHex:hex alpha:1]


/**
 *	生成二进制颜色
 *
 *	@param 	hex 	颜色描述字符串，带“0x”开头
 *  @param 	_alpha 	透明度
 *
 *	@return	UIColor对象
 */
#define DEF_HEXA_COLOR(hex, _alpha) [UIColor colorWithRGBHex:hex alpha:_alpha]


/**
 *  判断屏幕尺寸是否为640*1136
 *
 *	@return	判断结果（YES:是 NO:不是）
 */
#define DEF_SCREEN_IS_640_1136 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//全局
#define G ([Global share])

#define NAV_HEIGHT IOS7?64:44

#define WEAKSELF typeof(self) __weak weakSelf = self;

//由角度获取弧度 有弧度获取角度
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(radian) (radian*180.0)/(M_PI)

//警告框
#define alert(title,msg,cancel) [[[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];



// 微软雅黑
#define YC_YAHEI_FONT(FONTSIZE) [UIFont fontWithName:@"MicrosoftYaHei" size:(FONTSIZE)]

// 当前语言
#define CURRENTLANGUAGE         ([[NSLocale preferredLanguages] objectAtIndex:0])


#define COLOR_f2f0f0  [UIColor colorWithHexString:@"#f2f0f0"]   //我的cell颜色  首页背景颜色
#define COLOR_fafafa  [UIColor colorWithHexString:@"#fafafa"]   //周围共有20份订单 背景
#define COLOR_f1f1f1  [UIColor colorWithHexString:@"#f1f1f1"]   //接单弹出框 背景
#define COLOR_f7f6f6  [UIColor colorWithHexString:@"#f7f6f6"]   //发单tabBar 颜色



#endif
