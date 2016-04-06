//
//  ConFunc.m
//  GNETS
//
//  Created by tcnj on 16/2/16.
//  Copyright © 2016年 CQZ. All rights reserved.
//

#import "ConFunc.h"
#import <QuartzCore/QuartzCore.h>


@implementation ConFunc
+(UIView *)createLineframe:(CGRect)frame
{
    UIView *lineView = [[UIView alloc] initWithFrame:frame];
    lineView.backgroundColor =[UIColor lightGrayColor];
    return lineView;
}
+ (BOOL)isFirstLaunching {
    BOOL firstLaunching = false;
    
    /// asd
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastAppVersion = [userDefaults objectForKey:@"LastAppVersion"];
    NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if ([lastAppVersion floatValue] < [currentAppVersion floatValue]) {
        [userDefaults setValue:currentAppVersion forKey:@"LastAppVersion"];
        [userDefaults synchronize];
        
        firstLaunching = true;
    }
    
    return firstLaunching;
}

+ (void)addTapGesturesWithView:(UIView*)view target:(id)target selector:(SEL)selector {
    view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [tapGesture setNumberOfTapsRequired:1];
    [view addGestureRecognizer:tapGesture];
}


+ (CGFloat)getLabelWidth:(UILabel *)label {
    label.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{NSFontAttributeName:label.font};
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, label.frame.size.height)options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.width;
}

+ (CGFloat)getLabelHeight:(UILabel *)label {
    
    label.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{NSFontAttributeName:label.font};
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width,MAXFLOAT)options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.height;
    
}

+ (CGSize)getLabelSize:(UILabel *)label {
    
    label.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{NSFontAttributeName:label.font};
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width,MAXFLOAT)options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size;
    
}

+ (CGSize)getStringSize:(NSString *)text strMaxWidth:(CGFloat )width fontSize:(UIFont *)fontSize{
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:fontSize forKey: NSFontAttributeName];
    CGSize size = CGSizeZero;
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    size = [text boundingRectWithSize:constraint
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:dict
                              context:nil].size;
    return size;
    //    }
    //    size = [text sizeWithFont:fontSize
    //            constrainedToSize:constraint
    //                lineBreakMode:NSLineBreakByWordWrapping];
    
    return size;
}
//
//+ (CGSize)getIOS6LabelSize:(UILabel *)label {
//    return [label.text sizeWithFont:label.font
//                  constrainedToSize:CGSizeMake(label.frame.size.width, MAXFLOAT)
//                      lineBreakMode:NSLineBreakByWordWrapping];
//}



// 正则判断电子邮箱的正确性
+ (BOOL)validateEmail:(NSString*)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValidate = [emailPredicate evaluateWithObject:emailStr];
    
    return isValidate;
}

+ (BOOL)validateQQ:(NSString *)QQNumber{
    
    NSString *QQRegex = @"^[1-9][0-9]{4,9}$";
    NSPredicate *QQPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", QQRegex];
    BOOL isValidate = [QQPredicate evaluateWithObject:QQNumber];
    
    return isValidate;
}

// 正则判断手机号码地址格式
+ (BOOL)validatePhoneNumber:(NSString*)phoneNumStr {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:phoneNumStr] == YES)
        || ([regextestcm evaluateWithObject:phoneNumStr] == YES)
        || ([regextestct evaluateWithObject:phoneNumStr] == YES)
        || ([regextestcu evaluateWithObject:phoneNumStr] == YES)
        || ([regextestphs evaluateWithObject:phoneNumStr] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)timestampToNow:(NSInteger)secondsSince1970 {
    NSDate *time =
    [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
    return [[self class] stringForAgoFromDate:time toDate:[NSDate date]];
}

+ (NSString *)stringForAgoFromDate:(NSDate *)fdate toDate:(NSDate *)tdate
{
    NSCalendar *calendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags =
    NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components =
    [calendar components:unitFlags fromDate:fdate toDate:tdate options:0];
    
    //TWLog(@"Year:%d Month:%d Day:%d Hour:%d Minute:%d Second:%d", components.year, components.month, components.day, components.hour, components.minute, components.second);
    
    NSString *agoStr = nil;
    if (components.year >= 0 && components.month >= 0) {
        if (components.day == 0) {
            if (components.hour == 0) {
                if (components.minute < 1.0) {
                    agoStr = @"刚刚";
                } else {
                    agoStr = [NSString stringWithFormat:@"%ld %@", (long)components.minute, @"分钟前"];
                }
            } else {
                agoStr = [NSString stringWithFormat:@"%ld %@", (long)components.hour, @"小时前"];
            }
        } else if (components.month == 0 && components.day > 0 && components.day < 7) {
            agoStr = [NSString stringWithFormat:@"%ld %@", (long)components.day, @"天前"];
        } else {
            agoStr = [[[self class] agoFormatter] stringFromDate:fdate];
        }
    } else {
        NSLog(@"Time advance !");
    }
    
    return agoStr;
}
//+ (NSDate *)getDateFrom:(NSString *)strDate
//{
//    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    [dateFormatter setDateFormat:DATE_FORMAT_YMDHMS];
//    NSDate *date =[dateFormatter dateFromString:strDate];
//    return date;
//}
#pragma mark - 获取方向
+ (NSString *)getHeadingDes:(CGFloat )heading;
{
    NSString *aStr = @"";
    
    if (heading >22.5 && heading <=67.5)
    {
        aStr = @"正北方向";
    }
    if(heading > 67.5 && heading <= 112.5)
    {
        aStr = @"正北方向";
    }
    if(heading > 112.5 && heading <= 157.5)
    {
        aStr = @"东南方向";
    }
    if(heading > 157.5 && heading <= 202.5)
    {
        aStr = @"正南方向";
    }
    if(heading > 202.5 && heading <= 247.5)
    {
        aStr = @"西南方向";
    }
    if(heading > 247.5 && heading <= 292.5)
    {
        aStr = @"正西方向";
    }
    if(heading > 292.5 && heading <= 337.5)
    {
        aStr = @"西北方向";
    }
    if(heading > 337.5 || heading <= 22.5)
    {
        aStr = @"正北方向";
    }
    
    return aStr;
}
#pragma mark - 获得版本号
+ (NSString *)getBuildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app build版本
    NSString *app_build = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleVersion"]];
    return app_build;
}

+ (NSDateFormatter*)agoFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter =[[NSDateFormatter alloc] init];
        // @"yyyy-MM-dd HH:mm:ss"
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formatter setLocale:locale];
        formatter.dateFormat =@"MM月dd日";
    });
    return formatter;
}


+ (void)dwMakeCircleOnView:(UIView *)tView {
    CGSize size = tView.bounds.size;
    
    CGFloat radius = size.width * .5f;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[[UIColor redColor] CGColor]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, size.width, radius);
    CGPathAddArc(path, NULL, size.width-radius, size.height-radius, radius, 0.0, M_PI*2, YES);
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    
    tView.layer.mask = shapeLayer;
}

+ (void)dwMakeTopRoundCornerWithRadius:(CGFloat)radius onLayer:(CALayer *)tLayer {
    CGSize size = tLayer.bounds.size;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, size.width, radius);
    CGPathAddArc(path, NULL, size.width-radius, radius, radius, 0, 3 * M_PI_2, YES);
    CGPathAddLineToPoint(path, NULL, radius, 0.0);
    CGPathAddArc(path, NULL, radius, radius, radius, 3 * M_PI_2, M_PI, YES);
    CGPathAddLineToPoint(path, NULL, 0, size.height);
    CGPathAddLineToPoint(path, NULL, size.width, size.height);
    CGPathAddLineToPoint(path, NULL, size.width, radius);
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    
    tLayer.mask = shapeLayer;
}

+ (void)setMaskWithUIBezierPath:(UIBezierPath *)bezierPath onView:(UIView *)tView {
    //蒙版
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [bezierPath CGPath];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.frame = tView.bounds;
    tView.layer.mask = maskLayer;
    //边框蒙版
    CAShapeLayer *maskBorderLayer = [CAShapeLayer layer];
    maskBorderLayer.path = [bezierPath CGPath];
    maskBorderLayer.fillColor = [[UIColor clearColor] CGColor];
    maskBorderLayer.strokeColor = tView.layer.borderColor;//边框颜色
    maskBorderLayer.lineWidth = tView.layer.borderWidth; //边框宽度
    [tView.layer addSublayer:maskBorderLayer];
}

+ (void)drawLineOnView:(UIView *)superView
             lineWidth:(CGFloat )width
          strokeColor :(UIColor *)color
            startPoint:(CGPoint )sPoint
              endPoint:(CGPoint )ePoint {
    CAShapeLayer *lineShape = nil;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    lineShape = [CAShapeLayer layer];
    lineShape.lineWidth = width;
    lineShape.lineCap = kCALineCapRound;
    lineShape.strokeColor = color.CGColor;
    CGPathMoveToPoint(linePath, NULL, sPoint.x , sPoint.y );
    CGPathAddLineToPoint(linePath, NULL, ePoint.x , ePoint.y);
    lineShape.path = linePath;
    CGPathRelease(linePath);
    [superView.layer addSublayer:lineShape];
}
+ (UIImage*) createImageWithColor:(UIColor*) color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}
#pragma mark -判断日期是今天，昨天还是明天
+(NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}
#pragma mark -时间间隔
+(NSInteger)getDaysFrom:(NSDate *)serverDate To:(NSDate *)endDate
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [gregorian setFirstWeekday:2];
    
    //去掉时分秒信息
    NSDate *fromDate;
    NSDate *toDate;
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:serverDate];
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:endDate];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return dayComponents.day;
}
#pragma mark - 替换字串
+ (NSString *)trimStringUUID:(NSMutableString *)aStr;
{
    //2 替换%2
    NSString *search2 = @"%2";
    NSString *replace2 = @"";
    NSRange range2 = [aStr rangeOfString:search2];
    while (range2.location != NSNotFound)
    {
        [aStr replaceCharactersInRange:range2 withString:replace2];
        range2 = [aStr rangeOfString:search2];
    }
    
    //查找全部匹配的，并替换  -
    NSString *search1 = @"-";
    NSString *replace1 = @"";
    NSRange range1 = [aStr rangeOfString:search1];
    while (range1.location != NSNotFound)
    {
        [aStr replaceCharactersInRange:range1 withString:replace1];
        range1 = [aStr rangeOfString:search1];
    }

    
    return aStr;
}



@end
@implementation NSMutableDictionary(setObjectWithNullValidate)

-(BOOL)setObjectWithNullValidate:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!anObject || !aKey)
    {
        return NO;
    }
    [self setObject:anObject forKey:aKey];
    return YES;
}

@end

@implementation NSMutableArray (addObjectWithNullValidate)

-(BOOL)addObjectWithNullValidate:(id)object
{
    if (!object)
    {
        return NO;
    }
    if ([object isKindOfClass:[NSString class]])
    {
        NSString *str = (NSString*)object;
        if (str.length == 0)
        {
            return NO;
        }
    }
    [self addObject:object];
    return YES;
}

@end

