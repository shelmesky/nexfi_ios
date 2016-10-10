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

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderIconView;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameWidth;

@property (nonatomic,strong) UserModel *user;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,weak) id<NFNearbyUserCellDelegate> delegate;

@end
