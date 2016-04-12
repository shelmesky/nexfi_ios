//
//  ChatInfoVC.h
//  Nexify
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "BaseVC.h"

@interface ChatInfoVC : BaseVC

@property (nonatomic, retain)UserModel *to_user;
@property (nonatomic ,strong)id<UDLink>link;


@end
