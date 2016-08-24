//
//  DocumentLoadVC.h
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"
#import "FileModel.h"
@interface DocumentLoadVC : BaseVC

/** 标题 */
@property (nonatomic, copy) NSString *titleStr;

/** 用于下载的model */
@property (nonatomic, strong) FileModel *currentFileModel;

@end
