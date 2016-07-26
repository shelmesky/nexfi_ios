//
//  LooseTextField.m
//  Nexfi
//
//  Created by fyc on 16/7/11.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "LooseTextField.h"

@implementation LooseTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBorderStyle:UITextBorderStyleNone];
    
    [self setFont: [UIFont systemFontOfSize:17]];
    [self setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    [self.layer setBorderWidth: 1];
    [self.layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
    //    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
    
    [self.layer setCornerRadius:3.0];
    
}
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //        [super initWithFrame:frame];
        
        [self setBorderStyle:UITextBorderStyleNone];
        
        [self setFont: [UIFont systemFontOfSize:17]];
        [self setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self.layer setBorderWidth: 1];
        [self.layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
        //    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
        [self.layer setCornerRadius:3.0];
    }
    return self;
}
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 5);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 5);
}
//复写了layer方法  在vc写相当于没什么用了
//- (void)layoutSublayersOfLayer:(CALayer *)layer
//{
//    [super layoutSublayersOfLayer:layer];
//
//    [layer setBorderWidth: 1];
//    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
////    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
//
//    [layer setCornerRadius:3.0];
//    [layer setShadowOpacity:1.0];
//    [layer setShadowColor:[UIColor redColor].CGColor];
//    [layer setShadowOffset:CGSizeMake(1.0, 1.0)];
//}

- (void) drawPlaceholderInRect:(CGRect)rect {
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : [UIColor colorWithRed:182/255. green:182/255. blue:183/255. alpha:1.0]};
    [self.placeholder drawInRect:CGRectInset(rect, 5, 5) withAttributes:attributes];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
