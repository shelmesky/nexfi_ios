//
//  NSFileManager+Handle.h
//  Nexfi
//
//  Created by fyc on 16/8/25.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Handle)

/**
 *移除所有type文件
 */
- (void)removeTypeFile:(NSString *)type;

/**
 *删除所有Document目录下文件
 */
- (void)deleteDocumentDirectoryAllFilePath;

/**
 *获取Document文件目录下所有文件路径和路径名
 */
- (NSMutableArray *)getAllDucumentDirectoryPathAndFileName;

/**
 *获取Document文件路径
 */
+ (NSString *)getDocumentDirectoryPath;

@end

//@interface File : NSObject
//
//@property (nonatomic, retain)NSString *fileName;
//@property (nonatomic, retain)NSString *abosoluteFilePath;
//
//@end
