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
#pragma -mark 创建表
- (void)creatTable{
    if (![db open]) {
        NSLog(@"open db fail");
    }else{
        //用户表
        [db executeUpdate:@"create table if not exists nexfi_chat_user (userId text , headImgStr text, userName text,send_time text,lastmsg text, unreadnum integer default 0)"];
        //双方聊天表
        [db executeUpdate:@"create table if not exists nexfi_chat (from_user_id text, to_user_id text,send_time text,msg_text text,msg_id text,filetype text,durational integer)"];
        
        //所有人的群聊
        [db executeUpdate:@"create table if not exists nexfi_allUser_chat (userId text ,headImgStr text , userName text, send_time text, msg_text text, msg_id text , filetype text ,durational interger, isRead interger)"];
        
        //群聊（群组）
        [db executeUpdate:@"create table if not exists nexfi_group_chat (userId text , headImgStr text, userName text , send_time text, msg_text text, msg_id text, filetype text, groupId text , durational interger, isRead interger)"];
        
    }
}
#pragma -mark 获取所有人群聊的未读数
- (NSInteger)getUnreadNumOfAllUser_Chat{
    if ([db open]) {
        NSUInteger count = [db intForQuery:@"select sum(isRead) from nexfi_allUser_chat where isRead = 0"];
        return count;
    }
    return 0;
}
#pragma -mark 获取群聊未读数
- (NSInteger)getUnreadNumOfGroup_chatWithGroupId:(NSString *)groupId{
    if ([db open]) {
        NSUInteger count = [db intForQuery:@"select sum(isRead) from nexfi_group_chat where isRead = 0 and groupId = %@",groupId];
        return count;
    }
    return 0;
}
#pragma -mark 获取未读消息数
- (NSInteger)getUnreadNumOfMsg{
    if ([db open]) {
        NSUInteger count = [db intForQuery:@"select sum(unreadnum) from nexfi_chat_user where unreadnum > 0"];
        return count;
    }
    return 0;
}
#pragma -mark 获取未读的消息个数
-(NSInteger)getUnreadMessageCount:(NSString *) user_id
{
    //获取数据
    
    if ([db open]) {
        NSUInteger count = [db intForQuery:[NSString stringWithFormat:@"select sum(unreadnum) from nexfi_chat_user where unreadnum > 0 and user_id=%@",user_id]];
        //[db close];
        
        return count;
    }
    return 0;
}
#pragma -mark 插入总群聊数据
- (void)insertAllUser_ChatWith:(UserModel *)user WithMsg:(TribeMessage *)message{
    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
    
//        //插入之前去数据库 检查重复消息
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat"];
        NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];
        while ([rs next]) {
            
            
            NSString *msgId = [rs stringForColumn:@"msg_id"];
            
            [chatList addObject:msgId];
            
        }
        if ([chatList containsObject:message.msgId]) {//有的话就不插入
            return;
        }
        
        [dic setObject:user.userId forKey:@"userId"];
        [dic setObject:user.headImgPath forKey:@"headImgStr"];
        [dic setObject:user.userName forKey:@"userName"];
        [dic setObject:message.timestamp forKey:@"send_time"];
        [dic setObject:message.tContent forKey:@"msg_text"];
        [dic setObject:message.msgId forKey:@"msg_id"];
        [dic setObject:[NSString stringWithFormat:@"%ld",message.fileType] forKey:@"filetype"];
        [dic setObject:message.durational forKey:@"durational"];
        [dic setObject:message.isRead forKey:@"isRead"];
        
        
        [db executeUpdate:@"insert into nexfi_allUser_chat(userId,headImgStr,userName,send_time,msg_text,msg_id,filetype,durational,isRead)values(:userId, :headImgStr,:userName, :send_time, :msg_text, :msg_id, :filetype, :durational,:isRead)"withParameterDictionary:dic];
    }
    
}
#pragma -mark 插入群组消息
- (void)insertAllUser_ChatWith:(UserModel *)user WithMsg:(TribeMessage *)message WithGroupId:(NSString *)groupId{
    
    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
        [dic setObject:user.userId forKey:@"userId"];
        [dic setObject:user.headImgPath forKey:@"headImgStr"];
        [dic setObject:user.userName forKey:@"userName"];
        [dic setObject:message.timestamp forKey:@"send_time"];
        [dic setObject:message.tContent forKey:@"msg_text"];
        [dic setObject:message.msgId forKey:@"msg_id"];
        [dic setObject:[NSString stringWithFormat:@"%ld",message.fileType] forKey:@"filetype"];
        [dic setObject:message.durational forKey:@"durational"];
        [dic setObject:groupId forKey:@"groupId"];
        [dic setObject:message.isRead forKey:@"isRead"];
        
        [db executeUpdate:@"insert into nexfi_group_chat(userId,headImgStr,userName,send_time,msg_text,msg_id,filetype,groupId,durational,isRead)values(:userId,:headImgStr,:userName,:send_time,:msg_text,:msg_id,:filetype,:groupId,:durational,:isRead)"withParameterDictionary:dic];

    }
    
    
}
#pragma -mark 用户更新数据
- (void)updateUserHead:(UserModel *)userModel{
    
    if ([db executeUpdate:@"update nexfi_chat_user set headImgStr=? where userId = ?",userModel.headImgPath,userModel.userId]) {
        NSLog(@"更新nexfi_chat_user  头像信息成功");
    }
    if ([db executeUpdate:@"update nexfi_allUser_chat set headImgStr=? where userId =?",userModel.headImgPath,userModel.userId]) {
        NSLog(@"更新nexfi_allUser_chat  头像信息成功");
    }
    
}
- (void)updateUserName:(UserModel *)userModel{
    
    if ([db executeUpdate:@"update nexfi_chat_user set userName = ? where userId =?",userModel.userName,userModel.userId]) {
        NSLog(@"更新nexfi_allUser_chat  姓名成功");
    }
    if ([db executeUpdate:@"update nexfi_allUser_chat set userName=? where userId =?",userModel.userName,userModel.userId]) {
        NSLog(@"更新nexfi_allUser_chat  姓名成功");
    }

    
}
#pragma -mark 插入某人－》某人数据
- (void)add_chatUser:(UserModel*)User WithTo_user:(UserModel *)toUser WithMsg:(PersonMessage *)message{
    if (message == nil)
    {
        return;
    }
    
    if ([db open]) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSString * chatToId;
        //我发别人
        if([message.sender isEqualToString:[[UserManager shareManager]getUser].userId])
        {
            [dict setObject:[[UserManager shareManager]getUser].userId forKey:@"from_user_id"];
            [dict setObject:message.receiver forKey:@"to_user_id"];
            chatToId = message.receiver;
            
        }else {//别人发我
            [dict setObject:message.sender forKey:@"from_user_id"];
            [dict setObject:[[UserManager shareManager]getUser].userId forKey:@"to_user_id"];
            chatToId = message.sender;
            
        }
        [dict setObject:message.msgId forKey:@"msg_id"];
        [dict setObject:message.pContent forKey:@"msg_text"];
        [dict setObject:message.timestamp forKey:@"send_time"];
        [dict setObject:message.durational forKey:@"durational"];
        [dict setObject:[NSString stringWithFormat:@"%ld",message.fileType] forKey:@"filetype"];
        
        
        [db executeUpdate:@"insert into nexfi_chat(from_user_id, to_user_id,send_time,msg_text,msg_id,filetype,durational) values(:from_user_id, :to_user_id,:send_time,:msg_text,:msg_id,:filetype,:durational)" withParameterDictionary:dict];
        
        //更新聊天页面最后一条消息
        [self update_chat_to_user:toUser WithMsg:message];
        
        if (![message.sender isEqualToString:[[UserManager shareManager]getUser].userId]) {
            [self addUnreadNum:chatToId];
        }
        //刷新未读消息UI 还有当前聊天页面UI
        
        
        
    }
}
#pragma -mark 更新用户数据
- (void)update_chat_to_user:(UserModel *)toUser WithMsg:(PersonMessage *)message{
    
    if (message == nil)
    {
        return;
    }
    
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from nexfi_chat_user where userId=%@",toUser.userId];
        NSUInteger count = [db intForQuery:sql];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //别人发我最后一条消息
        if([message.sender isEqualToString:toUser.userId])
        {
            [dict setObject:message.sender forKey:@"userId"];
            [dict setObject:message.senderNickName forKey:@"userName"];
            [dict setObject:message.senderFaceImageStr forKey:@"headImgStr"];
            
        }else{
            [dict setObject:message.receiver forKey:@"userId"];
            [dict setObject:toUser.userName forKey:@"userName"];
            [dict setObject:toUser.headImgStr forKey:@"headImgStr"];
        
        }
        
        [dict setObject:message.timestamp forKey:@"send_time"];
        
        if(message.fileType == eMessageBodyType_Voice){
            [dict setObject:@"[语音]" forKey:@"lastmsg"];
        }else if (message.fileType ==eMessageBodyType_Image){
            [dict setObject:@"[图片]" forKey:@"lastmsg"];
        }else{
            [dict setObject:message.pContent forKey:@"lastmsg"];
        }
        
        if (count == 0) {
            [db executeUpdate:@"insert into nexfi_chat_user(userId,headImgStr,userName,send_time,lastmsg,unreadnum) values(:userId,:headImgStr,:userName,:send_time,:lastmsg,0)"withParameterDictionary:dict];
        }else{
            [db executeUpdate:@"update nexfi_chat_user set userName=:userName,headImgStr=:headImgStr,send_time=:send_time,lastmsg=:lastmsg where userId=:userId"withParameterDictionary:dict];
            
            NSLog(@"更新聊天用户信息");
            
        }
        

    }
}
#pragma -mark 清空群组未读消息
- (void)clearMsgOfGroup:(NSString *)groupId{
    if ([db open]) {
        if ([db executeUpdate:@"update nexfi_group_chat set isRead = 1 where groupId=?",groupId]) {
            NSLog(@"清空群组消息成功");
        }
    }
}
#pragma -mark 清空总群未读消息
- (void)clearMsgOfAllUser{
    if ([db open]) {
        if ([db executeUpdate:@"update nexfi_allUser_chat set isRead = 1"]) {
            NSLog(@"清空总群消息成功");
        }
    }
}
#pragma -mark 增加未读消息
-(void)addUnreadNum:(NSString*)user_id
{
    if ([db open]) {
        
        [db executeUpdate:@"UPDATE nexfi_chat_user SET unreadnum=unreadnum+1 WHERE userId = ?",user_id];

    }
    
}
#pragma -mark 清空未读消息
-(void)clearUnreadNum:(NSString*)user_id
{
    if ([db open]) {
        
        [db executeUpdate:@"UPDATE nexfi_chat_user SET unreadnum= 0 where userId = ?",user_id];
        
        //[db close];
        
    }
}
#pragma -mark 删除联系人的聊天记录
-(void)deleteTalk:(NSString *)user_id
{
    if ([db open]) {
        

        //删除聊天窗口
        [db executeUpdate:[NSString stringWithFormat:@"delete from nexfi_chat_user where user_id=%@",user_id]];
        //删除聊天内容nexfi_chat
        [db executeUpdate:[NSString stringWithFormat:@"delete from nexfi_chat  where from_user_id=%@ or to_user_id =%@",user_id,user_id]];
 
    }
}
#pragma -mark 删除所有人的聊天记录
- (void)deleteAllTalk{
    if ([db open]) {
   
        //删除聊天窗口
        [db executeUpdate:@"delete from nexfi_chat_user"];
        //删除聊天内容
        [db executeUpdate:@"delete from nexfi_chat"];
        
        
    }
}
#pragma -mark 查询总群聊的所有msgId
- (NSMutableArray *)getAllChatMsgIdList{
    
    NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    if ([db open]) {
        
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat"];
        
        while ([rs next]) {
            
            
            NSString *msgId = [rs stringForColumn:@"msg_id"];
            
            [chatList addObject:msgId];
            
        }
        
    }
    
    return chatList;
    
}
#pragma -mark 查询总群聊的历史纪录
- (NSMutableArray *)getAllChatListWithNum:(NSInteger)num{
    
    NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];

    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
//        
//        [dic setObject:[NSString stringWithFormat:@"%ld",num] forKey:@"startNum"];
//        [dic setObject:[NSString stringWithFormat:@"%ld",num + 20] forKey:@"endNum"];
        
//        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat order by send_time desc limit :startNum,:endNum"withParameterDictionary:dic];
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat order by send_time asc"];
        
        while ([rs next]) {
            
            TribeMessage *message = [[TribeMessage alloc]init];
            
            message.sender = [rs stringForColumn:@"userId"];
            message.senderFaceImageStr = [rs stringForColumn:@"headImgStr"];
            message.senderNickName = [rs stringForColumn:@"userName"];
            message.timestamp = [rs stringForColumn:@"send_time"];
            message.tContent = [rs stringForColumn:@"msg_text"];
            message.msgId = [rs stringForColumn:@"msg_id"];
            message.fileType = [[rs stringForColumn:@"filetype"] intValue];
            message.durational = [NSString stringWithFormat:@"%d",[rs intForColumn:@"durational"]];
            message.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
            
            [chatList addObject:message];
            
        }
        
    }
    
    return chatList;
}
#pragma -mark 查询群聊的历史纪录
- (NSMutableArray *)getGroupChatListWithNum:(NSInteger)num WithGroupId:(NSString *)groupId{
    
    NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
        
        [dic setObject:[NSString stringWithFormat:@"%ld",num] forKey:@"startNum"];
        [dic setObject:[NSString stringWithFormat:@"%ld",num + 20] forKey:@"endNum"];
        [dic setObject:groupId forKey:@"groupId"];
        
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_group_chat where groupId=:groupId order by send_time desc limit :startNum,:endNum"withParameterDictionary:dic];
        
        while ([rs next]) {
            
            TribeMessage *message = [[TribeMessage alloc]init];
            
            message.sender = [rs stringForColumn:@"userId"];
            message.senderFaceImageStr = [rs stringForColumn:@"headImgStr"];
            message.senderNickName = [rs stringForColumn:@"userName"];
            message.timestamp = [rs stringForColumn:@"send_time"];
            message.tContent = [rs stringForColumn:@"msg_text"];
            message.msgId = [rs stringForColumn:@"msg_id"];
            message.fileType = [[rs stringForColumn:@"filetype"] intValue];
            message.durational = [NSString stringWithFormat:@"%d",[rs intForColumn:@"durational"]];
            message.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
            message.groupId = [rs stringForColumn:@"groupId"];
            [chatList addObject:message];
            
        }
        
    }
    
    return chatList;
}
#pragma -mark 查询聊天历史纪录
-(NSMutableArray *)getChatHistory:(NSString *) fromId withToId:(NSString *) toId withStartNum:(NSInteger) num
{
    //获取数据
    NSMutableArray * recordArray = [[NSMutableArray alloc] init];
    
    //FMDatabase * db = [[FMDatabase alloc] initWithPath:[self getPath]];
    if ([db open]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:fromId forKey:@"from_user_id"];
        [dict setObject:toId forKey:@"to_user_id"];
        [dict setObject:[NSString stringWithFormat: @"%ld", num] forKey:@"startNum"];
        [dict setObject:[NSString stringWithFormat: @"%ld", num+30] forKey:@"endNum"];
        
//        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat where from_user_id=:from_user_id or to_user_id=:to_user_id order by send_time asc limit :startNum,:endNum" withParameterDictionary:dict];
        
          FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat where from_user_id=:from_user_id or to_user_id=:to_user_id order by send_time asc" withParameterDictionary:dict];
        
        //FMResultSet *rs  = [db executeQuery:[NSString stringWithFormat:@"select * from letmedo_chat where from_user_id=%@ or to_user_id=%@ order by public_time desc limit :startNum,:endNum",fromId,toId]];
        
        //FMResultSet *rs  = [db executeQuery:[NSString stringWithFormat:@"select count(*) from letmedo_chat"]];
        
        PersonMessage * msg;
        while ([rs next]){
            NSLog(@"dad");
            
            msg = [[PersonMessage alloc] init];
            msg.sender = [rs stringForColumn:@"from_user_id"];
            msg.receiver = [rs stringForColumn:@"to_user_id"];
            
            msg.pContent = [rs stringForColumn:@"msg_text"];
            msg.timestamp = [rs stringForColumn:@"send_time"];
            
            msg.durational = [rs stringForColumn:@"durational"];
            msg.fileType = [[rs stringForColumn:@"filetype"] intValue];
            [recordArray addObject: msg];
        }
        [rs close];
        
        //[db close];
    }
    return recordArray;
}
#pragma -mark 获取所有聊天名单
- (NSMutableArray *)getAllChatUserList{
    NSMutableArray *allUser = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat_user order by send_time desc"];
        UserModel *user = [[UserModel alloc]init];;
        while ([rs next]) {
            user.userId = [rs stringForColumn:@"userId"];
            user.userName = [rs stringForColumn:@"userName"];
            user.headImgStr = [rs stringForColumn:@"headImgStr"];
            user.lastmsg = [rs stringForColumn:@"lastmsg"];
            user.send_time = [rs stringForColumn:@"send_time"];
            user.unreadnum = [NSString stringWithFormat:@"%d",[rs intForColumn:@"unreadnum"]];
            
            [allUser addObject:user];
        }
    }
    
    return allUser;
}
#pragma -mark 查询聊天好友信息
- (UserModel *)getChatUserInfo:(NSString *)userId{
    UserModel *user;
    
    FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat_user where userId = %@",userId];
    
    while ([rs next]) {
        user.userId = [rs stringForColumn:@"userId"];
        user.userName = [rs stringForColumn:@"userName"];
        user.headImgStr = [rs stringForColumn:@"headImgStr"];
        user.lastmsg = [rs stringForColumn:@"lastmsg"];
        user.send_time = [rs stringForColumn:@"send_time"];
        user.unreadnum = [NSString stringWithFormat:@"%d",[rs intForColumn:@"unreadnum"]];
    }
    
    return user;
    
}
@end
