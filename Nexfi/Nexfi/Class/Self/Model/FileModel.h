//
//  FileModel.h
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject<NSCoding>


@property (nonatomic, copy) NSString *fileId;
//@property (nonatomic, copy) NSString *vFileName;
@property (nonatomic, copy) NSString *vContentType;
@property (nonatomic, copy) NSString *vUrl;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *vFileId;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileType;

// 注意这里一定要是：KB,MB,GB,Bytes
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, copy) NSString *attachmentFileSize;

/** 如果是本地的，绝对路径 */
@property (nonatomic, copy) NSString *fileAbsolutePath;

@end
