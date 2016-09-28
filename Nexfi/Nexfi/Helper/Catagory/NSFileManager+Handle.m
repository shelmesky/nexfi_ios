//
//  NSFileManager+Handle.m
//  Nexfi
//
//  Created by fyc on 16/8/25.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NSFileManager+Handle.h"
#import "FileModel.h"
@implementation NSFileManager (Handle)
//获取Document文件路径
+ (NSString *)getDocumentDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}
- (NSString *)getDocumentDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}
//获取Document文件目录下所有文件路径和路径名
+ (NSMutableArray *)getAllDucumentDirectoryPathAndFileName{
    NSString *directoryPath = [self getDocumentDirectoryPath];
    NSFileManager *file = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [file enumeratorAtPath:directoryPath];
    NSMutableArray *files = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSString *fileName in enumerator) {
        if (fileName.pathExtension && ![fileName.pathExtension isEqualToString:@""]) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [[fileName componentsSeparatedByString:@"/"] lastObject];
            file.fileAbsolutePath = [directoryPath stringByAppendingPathComponent:fileName];
            [files addObject:file];
        }
    }
    return files;
}
//获取某个文件目录下所有文件路径和路径名
+ (NSMutableArray *)getAllDirectoryPathAndFileNameWithDirectoryName:(NSString *)directoryName{
    NSFileManager *file = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [file enumeratorAtPath:directoryName];
    NSMutableArray *files = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSString *fileName in enumerator) {
        if (fileName.pathExtension && ![fileName.pathExtension isEqualToString:@""]) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [[fileName componentsSeparatedByString:@"/"] lastObject];
            file.fileAbsolutePath = [directoryName stringByAppendingPathComponent:fileName];
            [files addObject:file];
        }
    }
    return files;
}
//删除所有Document文件
- (void)deleteDocumentDirectoryAllFilePath{
    NSString *directoryPath = [self getDocumentDirectoryPath];
    NSFileManager *file = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [file enumeratorAtPath:directoryPath];
    for (NSString *fileName in enumerator) {
        if (fileName.pathExtension && ![fileName.pathExtension isEqualToString:@""]) {
            [file removeItemAtPath:[directoryPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}
//移除所有type文件
- (void)removeTypeFile:(NSString *)type{
    NSString *extension = type;
    NSString *directoryPath = [self getDocumentDirectoryPath];
    NSFileManager *file = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [file enumeratorAtPath:directoryPath];
    for (NSString *fileName in enumerator) {
        if ([fileName.pathExtension isEqualToString:extension]) {
            [file removeItemAtPath:[directoryPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

@end
