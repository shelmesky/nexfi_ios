//
//  MapTypeView.m
//  GNETS
//
//  Created by cqz on 16/3/1.
//  Copyright © 2016年 CQZ. All rights reserved.
//

#import "MapTypeView.h"
#import "UIView+Tap.h"

#define xSpace 10
#define LabSpace 20
@interface MapTypeView()

@property (nonatomic,strong) UIImageView *satelliteView;
@property (nonatomic,strong) UILabel *satelliteLab;
@property (nonatomic,strong) UIImageView *planeView;
@property (nonatomic,strong) UILabel *planeLab;

@end
@implementation MapTypeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
//        self.layer.masksToBounds = YES;
//        self.layer.cornerRadius = 5.f;
        self.backgroundColor = RGBACOLOR(240, 240, 240, 1);
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = .5f;

        [self initView];
        
    }
    return self;
}
- (void)initView
{
    _satelliteView = [[UIImageView alloc] init];
    _satelliteView.image = [UIImage imageNamed:@"satellite"];
    _satelliteView.userInteractionEnabled = YES;
    [self addSubview:_satelliteView];
    
    [_satelliteView whenTapped:^{
        
        if ([self.delegate respondsToSelector:@selector(changeMAMapType:)]) {
            [self.delegate changeMAMapType:@"卫星图"];
        }
        _satelliteView.image = [UIImage imageNamed:@"satellite_hover"];
        _planeView.image = [UIImage imageNamed:@"plane"];

        [[NSUserDefaults standardUserDefaults] setObject:@"卫星图" forKey:@"MAMapType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
    _planeView = [[UIImageView alloc] init];
    _planeView.image = [UIImage imageNamed:@"plane_hover"];
    _planeView.userInteractionEnabled = YES;
    [self addSubview:_planeView];
    
    [_planeView whenTapped:^{
        if ([self.delegate respondsToSelector:@selector(changeMAMapType:)]) {
            [self.delegate changeMAMapType:@"平面图"];
        }
        _satelliteView.image = [UIImage imageNamed:@"satellite"];
        _planeView.image = [UIImage imageNamed:@"plane_hover"];

        [[NSUserDefaults standardUserDefaults] setObject:@"平面图" forKey:@"MAMapType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
    NSString *typeStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"MAMapType"];
    
    if (typeStr.length>0)
    {
        if ([typeStr isEqualToString:@"卫星图"]) {
            _satelliteView.image = [UIImage imageNamed:@"satellite_hover"];
            _planeView.image = [UIImage imageNamed:@"plane"];

        }else{
            _satelliteView.image = [UIImage imageNamed:@"satellite"];
            _planeView.image = [UIImage imageNamed:@"plane_hover"];

        }
        
        
    }else{
        _planeView.image = [UIImage imageNamed:@"plane_hover"];
        _satelliteView.image = [UIImage imageNamed:@"satellite"];
        
    }
    

    
    _satelliteLab = [[UILabel alloc] init];
    _satelliteLab.textAlignment = NSTextAlignmentCenter;
    _satelliteLab.font = [UIFont systemFontOfSize:13.0];
    _satelliteLab.text = @"卫星图";
    [self addSubview:_satelliteLab];
    
    _planeLab = [[UILabel alloc] init];
    _planeLab.textAlignment = NSTextAlignmentCenter;
    _planeLab.font = [UIFont systemFontOfSize:13.0];;
    _planeLab.text = @"平面图";
    [self addSubview:_planeLab];

}

- (void)layoutSubviews
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    _satelliteView.frame = CGRectMake(10, 10, (width-40.f)/2, height-40);
    _planeView.frame = CGRectMake(30+(width-40.f)/2, 10, (width-40.f)/2, height-40);
    _satelliteLab.frame = CGRectMake(10, height-25, (width-40.f)/2, 20);
    _planeLab.frame = CGRectMake(30+(width-40.f)/2, height-25, (width-40.f)/2, 20);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
