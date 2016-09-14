//
//  SendFileVC.h
//  Nexfi
//
//  Created by fyc on 16/9/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"
#import "FileModel.h"
@interface SendFileVC : BaseVC

/** 用于下载的model */
@property (nonatomic, strong) FileModel *currentFileModel;

@end
