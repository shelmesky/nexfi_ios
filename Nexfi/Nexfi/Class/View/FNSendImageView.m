//
//  FNSendImageView.m
//  Nexfi
//
//  Created by fyc on 16/4/14.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "FNSendImageView.h"


@interface FNSendImageView()

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;


@end
@implementation FNSendImageView



- (instancetype)init {
    if ([super init]) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.hidden = YES;
        [self addSubview:self.indicatorView = indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.frame = self.bounds;
}

#pragma mark - Setters
- (void)setMessageSendState:(FNMessageSendState)messageSendState {
    _messageSendState = messageSendState;
    if (_messageSendState == FNMessageSendStateSending) {
        [self.indicatorView startAnimating];
        self.indicatorView.hidden = NO;
    }else {
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
    }
    
    switch (_messageSendState) {
        case FNMessageSendStateSending:
        case FNMessageSendFail:
            self.hidden = NO;
            break;
        default:
            self.hidden = YES;
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
