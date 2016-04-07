//
//  FCHeadCollectionCell.h
//  collectionTestVC
//
//  Created by fyc on 15/12/23.
//  Copyright © 2015年 FuYaChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCHeadCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLa;

@property (nonatomic, retain)UIView *backView;


@end
