//
//  NFAllUserChatInfoVC.h
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"

@interface NFAllUserChatInfoVC : BaseVC

@property (nonatomic ,strong)id<UDLink>link;
@property (nonatomic, strong)NSString *peersCount;

- (void)updatePeersCount:(NSString *)peersCount;
@end
