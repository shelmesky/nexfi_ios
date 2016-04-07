//
//  NFHeadVC.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"

@protocol NFHeadVCDelegate <NSObject>

//- (void)allProblems;
//- (void)refreshTable:(NSUInteger)index;
- (void)refeshHeightOfHeadView:(CGFloat)height; //刷新collection的高度
- (void)addTribeClicks:(id)sender;  //加入群聊
- (void)imgClick:(id)sender;  //点击图片

@end

@interface NFHeadVC : BaseVC

@property (nonatomic,strong)UICollectionView *collectionView;

@property (nonatomic,assign)id<NFHeadVCDelegate>delegate;

@end
