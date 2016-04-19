//
//  JXImageView.h
//  textScr
//
//  Created by JK PENG on 11-8-17.
//  Copyright 2011年 Devdiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol JXImageViewDelegate <NSObject>

- (void)tapImage:(id)sender;

@end

@interface JXImageView : UIImageView<UIGestureRecognizerDelegate> {
	SEL			_didTouch;
    int         _oldAlpha;
    BOOL        changeAlpha;
    NSString * _imageType;
}
@property (nonatomic, assign)id<JXImageViewDelegate>JXImageDelegate;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) BOOL      changeAlpha;
@property (nonatomic, assign) NSString *imageType;
@end
