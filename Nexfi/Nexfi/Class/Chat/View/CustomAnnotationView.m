//
//  CustomAnnotationView.m
//  Nexfi
//
//  Created by fyc on 16/7/29.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"


#define kWidth  150.f
#define kHeight 60.f

#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define kCalloutWidth   200.0
#define kCalloutHeight  70.0
@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation CustomAnnotationView

- (void)btnAction
{
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    
    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(chatToSb:)]) {
    
        [self.customDelegate chatToSb:self];
        
    }
}

#pragma mark - Override

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, 70, 60)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(10, 10, 50, 30);
            [btn setTitle:@"私聊" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            UIColor *c = [UIColor colorWithRed:81/255.0 green:186/255.0 blue:77/255.0 alpha:1];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.backgroundColor = c;
            [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            
            [self.calloutView addSubview:btn];
            
            
            
//            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
//            name.backgroundColor = [UIColor clearColor];
//            name.textColor = [UIColor whiteColor];
//            name.text = @"Hello Amap!";
//            [self.calloutView addSubview:name];
        }
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 60, 80);
        
        self.backgroundColor = [UIColor grayColor];
        
        /* Create portrait image view and add to view hierarchy. */
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitHeight)];
        [self addSubview:self.portraitImageView];
        
        /* Create name label. */
//        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitWidth + kHoriMargin,
//                                                                   kVertMargin,
//                                                                   kWidth - kPortraitWidth - kHoriMargin,
//                                                                   kHeight - 2 * kVertMargin)];
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(kHoriMargin, CGRectGetMaxY(self.portraitImageView.frame), CGRectGetWidth(self.portraitImageView.frame), 20)];
        self.nameLabel.backgroundColor  = [UIColor clearColor];
        self.nameLabel.textAlignment    = NSTextAlignmentCenter;
        self.nameLabel.textColor        = [UIColor whiteColor];
        self.nameLabel.font             = [UIFont systemFontOfSize:12.f];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
//        [self addSubview:self.nameLabel];
        
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
