//
//  ConFunc.h
//  GNETS
//
//  Created by tcnj on 16/2/16.
//  Copyright © 2016年 CQZ. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ConFunc : NSObject

+ (BOOL)isFirstLaunching;
+ (void)addTapGesturesWithView:(UIView*)view target:(id)target selector:(SEL)selector;

+(UIView *)createLineframe:(CGRect)frame;

+ (CGSize)getLabelSize:(UILabel *)label;
+ (CGFloat)getLabelWidth:(UILabel *)label;
+ (CGFloat)getLabelHeight:(UILabel *)label;
+ (CGSize)getStringSize:(NSString *)text strMaxWidth:(CGFloat )width fontSize:(UIFont *)fontSize;

+ (BOOL)validateEmail:(NSString*)emailStr;
+ (BOOL)validateQQ:(NSString *)QQNumber;
+ (BOOL)validatePhoneNumber:(NSString*)phoneNumStr;

+ (NSString *)timestampToNow:(NSInteger)secondsSince1970;
+ (NSString *)stringForAgoFromDate:(NSDate *)fdate toDate:(NSDate *)tdate;
+ (NSDate *)getDateFrom:(NSString *)strDate;
#pragma mark - 获取方向
+ (NSString *)getHeadingDes:(CGFloat )heading;
#pragma mark - 获得版本号
+ (NSString *)getBuildVersion;

+ (NSDateFormatter *)agoFormatter;

+ (void)dwMakeCircleOnView:(UIView *)tView;
+ (void)dwMakeTopRoundCornerWithRadius:(CGFloat)radius onLayer:(CALayer *)tLayer;
+ (void)setMaskWithUIBezierPath:(UIBezierPath *)bezierPath onView:(UIView *)tView;
+ (void)drawLineOnView:(UIView *)superView
             lineWidth:(CGFloat )width
          strokeColor :(UIColor *)color
            startPoint:(CGPoint )sPoint
              endPoint:(CGPoint )ePoint;


+ (UIImage*) createImageWithColor:(UIColor*) color
                             size:(CGSize)size;

#pragma mark -判断日期是今天，昨天还是明天
+(NSString *)compareDate:(NSDate *)date;
#pragma mark -时间间隔
+(NSInteger)getDaysFrom:(NSDate *)serverDate To:(NSDate *)endDate;

#pragma mark -替换字串
+ (NSString *)trimStringUUID:(NSMutableString *)aStr;

@end
/**
 * NSMutableDictionary扩展-防止字典被塞入nil而崩溃
 */
@interface NSMutableDictionary (setObjectWithNullValidate)

/**
 * 取代setObject:forKey
 */
- (BOOL)setObjectWithNullValidate:(id)anObject forKey:(id <NSCopying>)aKey;

@end
/**
 * NSMutableArray扩展-防止数组被塞入nil而崩溃
 */
@interface NSMutableArray (addObjectWithNullValidate)

/**
 * 取代addObject:
 */
- (BOOL)addObjectWithNullValidate:(id)object;

@end
