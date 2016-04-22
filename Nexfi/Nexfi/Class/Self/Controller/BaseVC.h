//
//  BaseVC.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController

@property (nonatomic,readonly)CGFloat contentOriginY;

- (void)leftButtonPressed:(UIButton *)sender;

- (void)rightButtonPressed:(UIButton *)sender;

- (void)setStrNavTitle:(NSString *)title;

/**
 *  创建右边按钮没有图片
 *
 *  @param title 设置右边按钮的title
 */
- (void)setRightButtonWithTitle:(NSString*)title WithTitleName:(NSString *)titleName;

- (void)setLeftButtonWithImageName:(NSString*)imageName bgImageName:(NSString*)bgImageName;

- (void)setRightButtonWithStateImage:(NSString *)iconName stateHighlightedImage:(NSString *)highlightIconName stateDisabledImage:(NSString *)disableIconName titleName:(NSString *)title;

/**
 *  向导航栏右边添加一个item,在原来的项的右边还是左边
 *
 *  @param button
 *  @param state
 */
- (void)appendRightBarItemWithCustomButton:(UIButton *)button toOldLeft:(BOOL)state;

-(void)setBaseVCAttributesWith:(NSString *)titleName left:(NSString*)nameLeft right:(NSString *)nameRight WithInVC:(UIViewController*)vc;

@end
