//
//  FCNearbyUserCell.h
//  jiaTingXianZhi
//
//  Created by ma on 15/12/30.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCNearbyUser;
@protocol NFNearbyUserCellDelegate <NSObject>
- (void)nearbyUserCellDidClickChatButtonForIndexPath:(NSIndexPath *)indexPath;
@end


@interface NFNearbyUserCell : UITableViewCell
@property (nonatomic,strong) UserModel *user;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,weak) id<NFNearbyUserCellDelegate> delegate;
@end
