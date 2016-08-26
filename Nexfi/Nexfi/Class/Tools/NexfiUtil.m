//
//  NexfiUtil.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NexfiUtil.h"
#import "SelfVC.h"
#import "NeighbourVC.h"
#import "NexfiNavigationController.h"
#import "UserInfoVC.h"
#import "AppDelegate.h"
#import "FileModel.h"

@implementation NexfiUtil
static NexfiUtil *_util;
+ (instancetype)shareUtil{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _util = [[NexfiUtil alloc]init];
    });
    return _util;
}
/**
 *@日期格式转换函数
 *date所要转化的日期 输入date格式为"yyyyMMddHHmmss"
 *type转化的格式  1:输出@"yyyy-MM-dd HH:mm:ss"
 *              2:输出@"yyyy-MM-dd"
 *              3:距离1970的时间戳输入date为时间戳 输出@"yyyy-MM-dd"
 *              4:输出@"yyyy年MM月dd日"
 *              5:输出@"yyyy-MM-dd HH:mm"
 **/
-(NSString *)switchDate:(NSString *)date returnType:(NSUInteger)type{
    if(date.length ==0){
        return @"";
    }
    NSString* string = date;
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    if (type == 3) {//时间戳转换成具体时间
        if (date.length>10)
            date = [date substringWithRange:NSMakeRange(0, 11)];
        //            date = [date substringFromIndex:0 toIndex:10];
        inputDate = [NSDate dateWithTimeIntervalSince1970:[date longLongValue]];
    }
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if (type == 1) {
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else if(type == 2){
        [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    else if(type == 3){
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else if(type == 4){
        [outputFormatter setDateFormat:@"yyyy年MM月dd日"];
    }
    else if(type == 5){
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    NSString *str = [outputFormatter stringFromDate:inputDate];
    return str;
}
#pragma mark -布局tabbar
- (void)layOutTheApp
{
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    //设定Tabbar的点击后的颜色 #ffa055
    [[UITabBar appearance] setTintColor:RGBACOLOR(56, 194, 58, 1)];
    //    [[UITabBar appearance]setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance]setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance]setBackgroundImage:[ConFunc createImageWithColor:RGBACOLOR(251, 251, 251, 1) size:CGSizeMake(SCREEN_SIZE.width,49)]];//设置背景，修改颜色是没有用的
    
    //设定Tabbar的颜色
    //    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    NexfiNavigationController *neighbouVC = [self newNavigationControllerForClass:[NeighbourVC class]
                                                                            title:@"附近"
                                                                        itemImage:@"btn-shouye"
                                                                    selectedImage:@"btn-shouye1"];
    NexfiNavigationController *selfVC = [self newNavigationControllerForClass:[SelfVC class]
                                                                        title:@"我的"
                                                                    itemImage:@"btn-账本2"
                                                                selectedImage:@"btn-账本1"];
    
    
    tabbar.viewControllers = @[neighbouVC,selfVC];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.tabbar = tabbar;
    window.rootViewController = app.tabbar;
}
- (NexfiNavigationController *)newNavigationControllerForClass:(Class)controllerClass
                                                         title:(NSString *)title
                                                     itemImage:(NSString *)itemImage
                                                 selectedImage:(NSString *)selectedImage
{
    UIViewController *viewController = [[controllerClass alloc] init];
    NexfiNavigationController *theNavigationController = [[NexfiNavigationController alloc]
                                                          initWithRootViewController:viewController];
    theNavigationController.tabBarItem.title = title;
    theNavigationController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    theNavigationController.tabBarItem.image = [[UIImage imageNamed:itemImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return theNavigationController;
}
//model转dic
+(NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int propsCount;
    
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        
        id value = [obj valueForKey:propName];
        
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}
+(void)print:(id)obj
{
    NSLog(@"%@",[self getObjectData:obj]);
}
+(NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error
{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}
+(id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]||[obj isKindOfClass:[NSNumber class]]|| [obj isKindOfClass:[NSNull class]]||[obj isKindOfClass:[NSData class]]||[obj isKindOfClass:[UIImage class]]||[obj isKindOfClass:[NSObject class]])
    {
        return obj;
    }
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    if([obj isKindOfClass:[NSDictionary class]])
    {
        
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
    
}
//自动生成uuid
+ (NSString*) uuid {
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    //        return [result autorelease];
    return result;
}
+(BOOL)isMeSend:(Message *)msg{
    
    return [msg.userMessage.userId isEqualToString:[[UserManager shareManager]getUser].userId];
    
}
//获取临时文件前缀
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix

{
    
    NSString * result;
    
    CFUUIDRef uuid;
    
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory()stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    
    assert(result != nil);
    
    CFRelease(uuidStr);
    
    CFRelease(uuid);
    
    return result;
   
}
//配置tabbar
- (void)configureTabVC{
    NexfiNavigationController *neighbouVC = [self newNavigationControllerForClass:[NeighbourVC class]
                                                                            title:@"附近"
                                                                        itemImage:@"btn-shouye"
                                                                    selectedImage:@"btn-shouye1"];
    NexfiNavigationController *selfVC = [self newNavigationControllerForClass:[SelfVC class]
                                                                        title:@"我的"
                                                                    itemImage:@"btn-账本2"
                                                                selectedImage:@"btn-账本1"];
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    
    
    [[UITabBar appearance]setBarTintColor:[UIColor whiteColor]];
    // 字体颜色 选中
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0F], NSForegroundColorAttributeName : [UIColor blueColor]} forState:UIControlStateSelected];
    
    tabbar.viewControllers = @[neighbouVC,selfVC];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    window.rootViewController = tabbar;
    
}
//计算字符数
+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}
+ (id)getVC_objectWithClassName:(NSString *)name{
    const char *className = [name cStringUsingEncoding:NSASCIIStringEncoding];
    Class newClass = objc_getClass(className);
    
    if (!className) {
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, className, 0);
        objc_registerClassPair(newClass);
    }
    
    return newClass;
}
//获取共享的文件路径和文件名字
+ (NSMutableArray *)getShareFileList{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentDirectory = [paths objectAtIndex:0];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:DocumentDirectory];
    NSMutableArray *files = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSString *fileName in enumerator) {
        if (fileName.pathExtension && ![fileName.pathExtension isEqualToString:@""]) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [[fileName componentsSeparatedByString:@"/"] lastObject];
            file.fileAbsolutePath = [DocumentDirectory stringByAppendingPathComponent:fileName];
            [files addObject:file];
        }
    }
    return files;
}
//移除所有png文件
- (void)removeTypeFile:(NSString *)type{
    NSString *extension = @"png";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [enumerator nextObject])) {
        if ([[filename pathExtension] isEqualToString:extension]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:nil];
        }
    }
}
//移除所有文件
- (void)removeAllFile{
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[DocumentsPath stringByAppendingPathComponent:fileName] error:nil];
    }
}
//获取所有文件
- (void)getAllFile{
    NSString *string = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:string error:nil]];
}
@end
