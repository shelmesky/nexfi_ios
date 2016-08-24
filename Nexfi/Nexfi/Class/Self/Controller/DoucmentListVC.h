//
//  DoucmentListVC.h
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"

@interface DoucmentListVC : BaseVC

/** 从appDelegate里面，跳转过来，主要用于打开别的软件的共享过来的文档 */
@property (nonatomic, copy) NSString *appFilePath;

@end
