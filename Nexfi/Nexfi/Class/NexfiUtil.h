//
//  NexfiUtil.h
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

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
@end
