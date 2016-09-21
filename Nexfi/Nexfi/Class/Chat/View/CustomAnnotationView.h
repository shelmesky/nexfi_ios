//
//  CustomAnnotationView.h
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@protocol CustomAnnotationDelegate <NSObject>

- (void)chatToSb:(id)sender;

@end

@interface CustomAnnotationView : BMKAnnotationView

@property (nonatomic, copy) NSString *name;//名字

@property (nonatomic, strong) UIImage *portrait;//头像

@property (nonatomic, strong) UIView *calloutView;//点击出现的view

@property (nonatomic, assign)id<CustomAnnotationDelegate>customDelegate;

@end
