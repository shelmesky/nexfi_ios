//
//  FileModel.m
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    /*
     @property (nonatomic, copy) NSString *fileId;
     @property (nonatomic, copy) NSString *vFileName;
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
     
     @property (nonatomic, copy) NSString *fileAbsolutePath;
    */
    
    
    [aCoder encodeObject:self.fileId forKey:@"fileId"];
//    [aCoder encodeObject:self.vFileName forKey:@"vFileName"];
    [aCoder encodeObject:self.vContentType forKey:@"vContentType"];
    [aCoder encodeObject:self.vUrl forKey:@"vUrl"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.vFileId forKey:@"vFileId"];
    [aCoder encodeObject:self.contentType forKey:@"contentType"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.fileType forKey:@"fileType"];
    [aCoder encodeObject:self.fileSize forKey:@"fileSize"];
    [aCoder encodeObject:self.attachmentFileSize forKey:@"attachmentFileSize"];
    [aCoder encodeObject:self.fileAbsolutePath forKey:@"fileAbsolutePath"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.fileId = [aDecoder decodeObjectForKey:@"fileId"];
//        self.vFileName = [aDecoder decodeObjectForKey:@"vFileName"];
        self.vContentType = [aDecoder decodeObjectForKey:@"vContentType"];
        self.vUrl = [aDecoder decodeObjectForKey:@"vUrl"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.vFileId = [aDecoder decodeObjectForKey:@"vFileId"];
        self.contentType = [aDecoder decodeObjectForKey:@"contentType"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.fileType = [aDecoder decodeObjectForKey:@"fileType"];
        self.fileSize = [aDecoder decodeObjectForKey:@"fileSize"];
        self.attachmentFileSize = [aDecoder decodeObjectForKey:@"attachmentFileSize"];
        self.fileAbsolutePath = [aDecoder decodeObjectForKey:@"fileAbsolutePath"];
    }
    return self;
}
@end
