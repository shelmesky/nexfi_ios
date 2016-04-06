//
//  JXSelectImageView.m
//
//  Created by Reese on 13-8-22.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXSelectImageView.h"
#define CHAT_BUTTON_SIZE 55
#define INSETS 10


@implementation JXSelectImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //写死面板的高度
        [self setBackgroundColor:[UIColor whiteColor]];
        
        
        // Initialization code
        _cameraButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setFrame:CGRectMake(INSETS, INSETS, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
        [_cameraButton setImage:[UIImage imageNamed:@"icon_camera_off"] forState:UIControlStateNormal];
        [_cameraButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(pickCamera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraButton];
        
        UILabel * _cameraText = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, CHAT_BUTTON_SIZE+10, CHAT_BUTTON_SIZE , 20)];
        [_cameraText setText:@"拍照"];
        [_cameraText setTextAlignment:NSTextAlignmentCenter];
        [_cameraText setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self addSubview:_cameraText];
        
        _photoButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setFrame:CGRectMake(INSETS+80, INSETS, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
        [_photoButton setImage:[UIImage imageNamed:@"icon_photo_off"] forState:UIControlStateNormal];
        [_cameraButton setTitle:@"图片" forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(pickPhoto) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_photoButton];
        
        
        UILabel * _photoText = [[UILabel alloc] initWithFrame:CGRectMake(INSETS+80, CHAT_BUTTON_SIZE+10, CHAT_BUTTON_SIZE , 20)];
        [_photoText setText:@"图片"];
        [_photoText setTextAlignment:NSTextAlignmentCenter];
        [_photoText setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self addSubview:_photoText];

        
    }
    return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)pickPhoto
{
    [_delegate pickPhoto];
}


-(void)pickCamera
{
    [_delegate pickCamera];
}


//-(UIImage *)imageDidFinishPicking
//{
//    
//}
//-(UIImage *)cameraDidFinishPicking
//{
//    
//}
//-(CLLocation *)locationDidFinishPicking
//{
//    
//}
-(void)dealloc
{
    [super dealloc];
    
}

@end
