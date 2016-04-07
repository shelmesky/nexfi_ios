//
//  FCTabHeadView.m
//  collectionTestVC
//
//  Created by fyc on 15/12/23.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//
//#define SCREEN_SIZE   [[UIScreen mainScreen] bounds].size

#import "FCTabHeadView.h"
#import "FCHeadCollectionCell.h"
#import "FCHeadAddCollectionCell.h"

@implementation FCTabHeadView
- (void)setDataArr:(NSMutableArray *)dataArr{
    if (_dataArr != dataArr) {
        _dataArr = dataArr;
    }
    [_dataArr addObject:@"1"];
    NSInteger row = _dataArr.count/5;
    _collectionView.frame = CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, (row+1)*90);
    [self.collectionView reloadData];
    
}
- (id)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(50 , 70);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, self.frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
        
    }
    return self;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath ==== %d",indexPath.row);
    [collectionView registerNib:[UINib nibWithNibName:@"FCHeadCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    FCHeadCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.item == _dataArr.count - 1) {
        [collectionView registerNib:[UINib nibWithNibName:@"FCHeadAddCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"addCell"];
        FCHeadAddCollectionCell *cells = [collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:indexPath];
        [cells.addTribe setTitle:@"" forState:UIControlStateNormal];
        [cells.addTribe setBackgroundImage:[UIImage imageNamed:@"102"] forState:UIControlStateNormal];
        [cells.addTribe addTarget:self action:@selector(addTribeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refeshHeightOfHeadView:)]) {
            [self.delegate refeshHeightOfHeadView:cells.frame.origin.y + cells.frame.size.height + 10];
        }
        
        return cells;
        
    }
    //    cell.backgroundColor = [UIColor blueColor];
    cell.headImg.tag = 10000 + indexPath.item;
    
    NSDictionary *d = [_dataArr objectAtIndex:indexPath.item];
    cell.nameLa.text = d[@"name"];
    cell.nameLa.textAlignment = NSTextAlignmentCenter;
    cell.headImg.image = d[@"head"];
    
    
    
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(50, 70);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FCHeadCollectionCell *cell = (FCHeadCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(imgClick:)]) {
        [self.delegate imgClick:cell];
    }
    
    
}
- (void)addTribeClick:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addTribeClicks:)]) {
        [self.delegate addTribeClicks:sender];
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
