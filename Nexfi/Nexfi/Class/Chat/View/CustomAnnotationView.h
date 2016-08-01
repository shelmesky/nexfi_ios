//
//  CustomAnnotationView.h
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, copy) NSString *name;//名字

@property (nonatomic, strong) UIImage *portrait;//头像

@property (nonatomic, strong) UIView *calloutView;//点击出现的view

@end