//
//  SqlManager.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SqlManager.h"
#import "FMDatabaseQueue.h"
@implementation SqlManager

static FMDatabase *db;
static SqlManager *_share = nil;

+ (SqlManager *)shareInstance{
    if (_share == nil) {
        _share = [[SqlManager alloc]init];
    }
    return _share;
}
- (void)reset{
    _share = nil;
}
- (id)init{
    self = [super init];
    if (self) {
        db = [FMDatabase databaseWithPath:[self getPath]];
    }
    return self;
}
- (NSString *)getPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fmdbPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"nexfi.db"];
    
    NSLog(@"fmdbPath ===%@",fmdbPath);
    
    return  fmdbPath;
}
- (void)creatTable{
    if (![db open]) {
        NSLog(@"open db fail");
    }else{
        //用户表
        [db executeUpdate:@"create table if not exists nexfi_chat_user (userId integer , userHead blob, userName text,send_time text,lastmsg text, unreadnum integer default 0)"];
        //双方聊天表
        [db executeUpdate:@"create table if not exists nexfi_chat (from_user_id integer, to_user_id integer,send_time text,msg_text text,msg_id text,filetype text, file blob,durational integer)"];
        
    }
}
//获取未读消息数
- (NSInteger)getUnreadNumOfMsg{
    if ([db open]) {
        NSUInteger count = [db intForQuery:@"select sum(unreadnum) from nexfi_chat_user where unreadnum > 0"];
        return count;
    }
    return 0;
}

@end
