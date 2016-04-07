//
//  FCTabHeadView.h
//  collectionTestVC
//
//  Created by fyc on 15/12/23.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCTabHeadViewDelegate <NSObject>

//- (void)allProblems;
//- (void)refreshTable:(NSUInteger)index;
- (void)refeshHeightOfHeadView:(CGFloat)height; //刷新collection的高度
- (void)addTribeClicks:(id)sender;  //加入群聊
- (void)imgClick:(id)sender;  //点击图片

@end

@interface FCTabHeadView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

{
    int a ;
}
@property (nonatomic,assign)id<FCTabHeadViewDelegate>delegate;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataArr;


@end
