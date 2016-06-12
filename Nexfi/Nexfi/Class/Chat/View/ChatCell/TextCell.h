//
//  TextCell.h
//  NexFiSDK
//
//  Created by fyc on 16/5/18.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"
@interface TextCell : ChatCell
@property (weak, nonatomic) IBOutlet UILabel *msgContent;
@property (weak, nonatomic) IBOutlet UIImageView *bubble;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgContentW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgContentH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleH;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameConstant;

@property (nonatomic, strong)Message *msg;

@end
