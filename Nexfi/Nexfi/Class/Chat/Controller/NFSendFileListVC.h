//
//  NFSendFileListVC.h
//  Nexfi
//
//  Created by fyc on 16/9/26.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"

typedef enum : NSUInteger {
    FileListModeNormal,
    FileListModeSingleSelection,
    FileListModeMultipleSelection
} FileListMode;
@protocol sendFileDelegate <NSObject>

- (void)sendFile:(FileModel *)file;

@end
@interface NFSendFileListVC : BaseVC


@property (nonatomic ,assign)FileListMode mode;
@property (nonatomic, retain)NSMutableArray *fileList;
@property (nonatomic, assign)id<sendFileDelegate>delegate;

@end
