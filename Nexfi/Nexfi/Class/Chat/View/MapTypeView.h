//
//  MapTypeView.h
//  GNETS
//
//  Created by cqz on 16/3/1.
//  Copyright © 2016年 CQZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapTypeViewPro <NSObject>

- (void)changeMAMapType:(NSString *)type;

@end

@interface MapTypeView : UIView

@property (nonatomic,weak)id<MapTypeViewPro>delegate;

-(id)initWithFrame:(CGRect)frame;
@end
