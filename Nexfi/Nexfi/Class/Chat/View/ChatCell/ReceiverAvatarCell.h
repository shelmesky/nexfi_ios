//
//  ReceiverAvatarCell.h
//  NexFiSDK
//
//  Created by fyc on 16/5/18.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"
@interface ReceiverAvatarCell : ChatCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *chatPic;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatPicH;
@property (nonatomic, strong)Message *msg;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameConstant;

@end
