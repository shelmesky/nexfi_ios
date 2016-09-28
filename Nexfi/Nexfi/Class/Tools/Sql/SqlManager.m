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
    
    NSString *fmdbPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"nexfi_%@.db",[[UserManager shareManager]getUser].userId]];
    
    NSLog(@"fmdbPath ===%@",fmdbPath);
    
    return  fmdbPath;
}
// 删除数据库
- (void)deleteDatabse
{
    BOOL success;
    NSError *error;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * fmdbPath  = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"nexfi_%@.db",[[UserManager shareManager]getUser].userId]];
    // delete the old db.
    if ([fileManager fileExistsAtPath:fmdbPath])
    {
        [db close];
        success = [fileManager removeItemAtPath:fmdbPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }
}
- (void)openDb{
    if ([db open]) {
        NSLog(@"open db success");
    }
}
#pragma -mark 创建表
- (void)creatTable{
    if (![db open]) {
        NSLog(@"open db fail");
    }else{
        //用户表
        [db executeUpdate:@"create table if not exists nexfi_chat_user (userId text , userAvatar text, userNick text , userAge text, userGender text, send_time text,lastmsg text, unreadnum integer default 0)"];
        //双方聊天表
        [db executeUpdate:@"create table if not exists nexfi_chat (from_user_id text, to_user_id text,send_time text,msg_text text,msg_id text,filetype text,fileName text,fileSize text,fileSufType text, filePath text, durational integer,isRead integer)"];
        
        //所有人的群聊
        [db executeUpdate:@"create table if not exists nexfi_allUser_chat (userId text ,userAvatar text , userNick text, userAge text, userGender text, send_time text, msg_text text, msg_id text , filetype text , fileName text,fileSize text,fileSufType text, filePath text, durational interger, isRead interger)"];
        
        //群聊（群组）
        [db executeUpdate:@"create table if not exists nexfi_group_chat (userId text , userAvatar text, userNick text , userAge text, userGender text, send_time text, msg_text text, msg_id text, filetype text, groupId text , fileName text,fileSize text,fileSufType text,filePath text, durational interger, isRead interger)"];
        
        //文件
        [db executeUpdate:@"create table if not exists nexfi_file (fileName text, fileAbosolutePath text, partPath text, fileType text, fileSize text, fileData text, fileKind text)"];
        
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
        [dic setObject:user.userAvatar forKey:@"userAvatar"];
        [dic setObject:user.userNick forKey:@"userNick"];
        [dic setObject:user.userGender forKey:@"userGender"];
        [dic setObject:[NSString stringWithFormat:@"%d",user.userAge] forKey:@"userAge"];
        [dic setObject:message.timeStamp forKey:@"send_time"];
        [dic setObject:message.msgId forKey:@"msg_id"];
        [dic setObject:[NSString stringWithFormat:@"%ld",message.messageBodyType] forKey:@"filetype"];
    
        
        NSString *content;
        NSString *durational;
        NSString *isRead;
        NSString *fileName;
        NSString *fileSufType;
        NSString *fileSize;
        NSString *filePath;
        if (message.messageBodyType == eMessageBodyType_Image) {
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Voice){
            
            content = message.voiceMessage.fileData;
            durational = message.voiceMessage.durational;
            isRead = message.voiceMessage.isRead;
            fileName = message.voiceMessage.fileName;
            fileSufType = message.voiceMessage.fileType;
            fileSize = message.voiceMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Text){
            
            content = message.textMessage.fileData;
            isRead = message.textMessage.isRead;
            
        }else if (message.messageBodyType == eMessageBodyType_File){
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            filePath = message.fileMessage.filePath;
            
        }//fileName text,fileSize text,fileSufType text
        [dic setObject:content forKey:@"msg_text"];
        if (durational) {
            [dic setObject:durational forKey:@"durational"];
        }
        if (isRead) {
            [dic setObject:isRead forKey:@"isRead"];
        }
        if (fileName) {
            [dic setObject:fileName forKey:@"fileName"];
        }
        if (fileSufType) {
            [dic setObject:fileSufType forKey:@"fileSufType"];
        }
        if (fileSize) {
            [dic setObject:fileSize forKey:@"fileSize"];
        }
        if (filePath) {
            [dic setObject:filePath forKey:@"filePath"];
        }
        if (message.messageBodyType == eMessageBodyType_Voice) {
            [db executeUpdate:@"insert into nexfi_allUser_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,durational,isRead,fileName,fileSize,fileSufType)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :durational, :isRead, :fileName, :fileSize, :fileSufType)"withParameterDictionary:dic];


        }else if (message.messageBodyType == eMessageBodyType_Text){
            [db executeUpdate:@"insert into nexfi_allUser_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,isRead)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :isRead)"withParameterDictionary:dic];
        }
        else if (message.messageBodyType == eMessageBodyType_Image){//图片
            [db executeUpdate:@"insert into nexfi_allUser_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,isRead,fileName,fileSize,fileSufType)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :isRead, :fileName, :fileSize, :fileSufType)"withParameterDictionary:dic];

        }else{
            [db executeUpdate:@"insert into nexfi_allUser_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,isRead,fileName,fileSize,fileSufType,filePath)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :isRead, :fileName, :fileSize, :fileSufType, :filePath)"withParameterDictionary:dic];
        }
        
    }
    
}
#pragma -mark 插入群组消息
- (void)insertAllUser_ChatWith:(UserModel *)user WithMsg:(TribeMessage *)message WithGroupId:(NSString *)groupId{
    
    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
        [dic setObject:user.userId forKey:@"userId"];
        [dic setObject:user.userAvatar forKey:@"userAvatar"];
        [dic setObject:user.userNick forKey:@"userNick"];
        [dic setObject:[NSString stringWithFormat:@"%d",user.userAge] forKey:@"userAge"];
        [dic setObject:user.userGender forKey:@"userGender"];
        [dic setObject:message.timeStamp forKey:@"send_time"];
        [dic setObject:message.msgId forKey:@"msg_id"];
        [dic setObject:[NSString stringWithFormat:@"%ld",message.messageBodyType] forKey:@"filetype"];
        [dic setObject:groupId forKey:@"groupId"];
        
        NSString *content;
        NSString *durational;
        NSString *isRead;
        NSString *fileName;
        NSString *fileSufType;
        NSString *fileSize;
        NSString *filePath;
        if (message.messageBodyType == eMessageBodyType_Image) {
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Voice){
            
            content = message.voiceMessage.fileData;
            durational = message.voiceMessage.durational;
            isRead = message.voiceMessage.isRead;
            fileName = message.voiceMessage.fileName;
            fileSufType = message.voiceMessage.fileType;
            fileSize = message.voiceMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Text){
            
            content = message.textMessage.fileData;
            isRead = message.textMessage.isRead;
            
        }else if (message.messageBodyType == eMessageBodyType_File){
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            filePath = message.fileMessage.filePath;
            
        }//fileName text,fileSize text,fileSufType text
        [dic setObject:content forKey:@"msg_text"];
        if (durational) {
            [dic setObject:durational forKey:@"durational"];
        }
        if (isRead) {
            [dic setObject:isRead forKey:@"isRead"];
        }
        if (fileName) {
            [dic setObject:fileName forKey:@"fileName"];
        }
        if (fileSufType) {
            [dic setObject:fileSufType forKey:@"fileSufType"];
        }
        if (fileSize) {
            [dic setObject:fileSize forKey:@"fileSize"];
        }
        if (filePath) {
            [dic setObject:filePath forKey:@"filePath"];
        }//nexfi_group_chat
        if (message.messageBodyType == eMessageBodyType_Voice) {
            
            [db executeUpdate:@"insert into nexfi_group_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,groupId,durational,isRead,fileName,fileSize,fileSufType)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :groupId, :durational, :isRead, :fileName, :fileSize, :fileSufType)"withParameterDictionary:dic];

        }else if (message.messageBodyType == eMessageBodyType_Text){
            
            [db executeUpdate:@"insert into nexfi_group_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,groupId,isRead)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :groupId, :isRead)"withParameterDictionary:dic];
            
        }else if(message.messageBodyType == eMessageBodyType_Image){
            
            [db executeUpdate:@"insert into nexfi_group_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,groupId,isRead,fileName,fileSize,fileSufType)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :groupId, :isRead, :fileName, :fileSize, :fileSufType)"withParameterDictionary:dic];

        }else{
            
            [db executeUpdate:@"insert into nexfi_group_chat(userId,userAvatar,userNick,userGender,userAge,send_time,msg_text,msg_id,filetype,groupId,isRead,fileName,fileSize,fileSufType,filePath)values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :msg_text, :msg_id, :filetype, :groupId, :isRead, :fileName, :fileSize, :fileSufType, :filePath)"withParameterDictionary:dic];
            
        }
        
    }
    
    
}
#pragma -mark 插入拷贝文件数据
- (void)insertFile:(FileModel *)file{
    if ([db open]) {
        //db executeUpdate:@"create table if not exists nexfi_file (fileName text, fileAbosolutePath text, partPath text, fileType text, fileSize text, fileData text, fileKind text)"];
        NSMutableDictionary *fileDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
        [fileDic setObject:file.fileName forKey:@"fileName"];
        [fileDic setObject:file.fileAbsolutePath forKey:@"fileAbosolutePath"];
        [fileDic setObject:file.partPath forKey:@"partPath"];
        [fileDic setObject:file.fileType forKey:@"fileType"];
        [fileDic setObject:file.fileSize forKey:@"fileSize"];
        [fileDic setObject:file.fileKind forKey:@"fileKind"];
        
         BOOL ha =[db executeUpdate:@"insert into nexfi_file (fileName, fileAbosolutePath, partPath, fileType, fileSize,  fileKind)values(:fileName, :fileAbosolutePath, :partPath, :fileType, :fileSize, :fileKind)"withParameterDictionary:fileDic];
        NSLog(@"ha=====%d",ha);
        
    }
}
#pragma -mark 用户更新数据
- (void)updateUserHead:(UserModel *)userModel{
    
    if ([db executeUpdate:@"update nexfi_chat_user set userAvatar=? where userId = ?",userModel.userAvatar,userModel.userId]) {
        NSLog(@"更新nexfi_chat_user  头像信息成功");
    }
    if ([db executeUpdate:@"update nexfi_allUser_chat set userAvatar=? where userId =?",userModel.userAvatar,userModel.userId]) {
        NSLog(@"更新nexfi_allUser_chat  头像信息成功");
    }
    
}
- (void)updateUserName:(UserModel *)userModel{
    
    if ([db executeUpdate:@"update nexfi_chat_user set userNick = ? where userId =?",userModel.userNick,userModel.userId]) {
        NSLog(@"更新nexfi_allUser_chat  姓名成功");
    }
    if ([db executeUpdate:@"update nexfi_allUser_chat set userNick=? where userId =?",userModel.userNick,userModel.userId]) {
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
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        NSString * chatToId;
        //我发别人
        
        if([message.userMessage.userId isEqualToString:[[UserManager shareManager]getUser].userId])
        {
            [dic setObject:[[UserManager shareManager]getUser].userId forKey:@"from_user_id"];
            [dic setObject:message.receiver forKey:@"to_user_id"];
            chatToId = message.receiver;
            
        }else {//别人发我
            [dic setObject:message.userMessage.userId forKey:@"from_user_id"];
            [dic setObject:[[UserManager shareManager]getUser].userId forKey:@"to_user_id"];
            chatToId = message.userMessage.userId;
            
        }
        NSString *content;
        NSString *durational;
        NSString *isRead;
        NSString *fileName;
        NSString *fileSufType;
        NSString *fileSize;
        NSString *filePath;
        if (message.messageBodyType == eMessageBodyType_Image) {
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Voice){
            
            content = message.voiceMessage.fileData;
            durational = message.voiceMessage.durational;
            isRead = message.voiceMessage.isRead;
            fileName = message.voiceMessage.fileName;
            fileSufType = message.voiceMessage.fileType;
            fileSize = message.voiceMessage.fileSize;
            
        }else if (message.messageBodyType == eMessageBodyType_Text){
            
            content = message.textMessage.fileData;
            isRead = message.textMessage.isRead;
            
        }else if (message.messageBodyType == eMessageBodyType_File){
            
            content = message.fileMessage.fileData;
            isRead = message.fileMessage.isRead;
            fileName = message.fileMessage.fileName;
            fileSufType = message.fileMessage.fileType;
            fileSize = message.fileMessage.fileSize;
            filePath = message.fileMessage.filePath;
            
        }
        //fileName text,fileSize text,fileSufType text
        [dic setObject:content forKey:@"msg_text"];
        if (durational) {
            [dic setObject:durational forKey:@"durational"];
        }
        if (isRead) {
            [dic setObject:isRead forKey:@"isRead"];
        }
        if (fileName) {
            [dic setObject:fileName forKey:@"fileName"];
        }
        if (fileSufType) {
            [dic setObject:fileSufType forKey:@"fileSufType"];
        }
        if (fileSize) {
            [dic setObject:fileSize forKey:@"fileSize"];
        }
        if (filePath) {
            [dic setObject:filePath forKey:@"filePath"];
        }
        
        [dic setObject:message.msgId forKey:@"msg_id"];
        [dic setObject:message.timeStamp forKey:@"send_time"];
        [dic setObject:[NSString stringWithFormat:@"%ld",message.messageBodyType] forKey:@"filetype"];
        
        if (message.messageBodyType == eMessageBodyType_Voice) {
            
            [db executeUpdate:@"insert into nexfi_chat(from_user_id, to_user_id,send_time,msg_text,msg_id,filetype,durational,isRead,fileName,fileSize,fileSufType) values(:from_user_id, :to_user_id, :send_time, :msg_text, :msg_id, :filetype, :durational, :isRead, :fileName, :fileSize, :fileSufType)" withParameterDictionary:dic];
            

        }else if (message.messageBodyType == eMessageBodyType_Text){
            
            [db executeUpdate:@"insert into nexfi_chat(from_user_id, to_user_id,send_time,msg_text,msg_id,filetype,isRead) values(:from_user_id, :to_user_id, :send_time, :msg_text, :msg_id, :filetype, :isRead)" withParameterDictionary:dic];
            
        }else if(message.messageBodyType == eMessageBodyType_Image){//图片
            BOOL a = [db executeUpdate:@"insert into nexfi_chat(from_user_id, to_user_id,send_time,msg_text,msg_id,filetype,isRead,fileName,fileSize,fileSufType) values(:from_user_id, :to_user_id, :send_time, :msg_text, :msg_id, :filetype, :isRead, :fileName, :fileSize, :fileSufType)" withParameterDictionary:dic];
            
            NSLog(@"a===%d",a);

        }else{
            [db executeUpdate:@"insert into nexfi_chat(from_user_id, to_user_id,send_time,msg_text,msg_id,filetype,isRead,fileName,fileSize,fileSufType,filePath) values(:from_user_id, :to_user_id, :send_time, :msg_text, :msg_id, :filetype, :isRead, :fileName, :fileSize, :fileSufType, :filePath)" withParameterDictionary:dic];
        }
        
        
        //更新聊天页面最后一条消息
        [self update_chat_to_user:toUser WithMsg:message];
        
        if (![message.userMessage.userId isEqualToString:[[UserManager shareManager]getUser].userId]) {
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
        NSLog(@"sql===+%d",count);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //别人发我最后一条消息
        if([message.userMessage.userId isEqualToString:toUser.userId])
        {
            [dict setObject:message.userMessage.userId forKey:@"userId"];
            [dict setObject:message.userMessage.userNick forKey:@"userNick"];
            [dict setObject:message.userMessage.userAvatar forKey:@"userAvatar"];
            [dict setObject:message.userMessage.userGender forKey:@"userGender"];
            [dict setObject:[NSString stringWithFormat:@"%d",message.userMessage.userAge] forKey:@"userAge"];
            
            
        }else{
            [dict setObject:message.receiver forKey:@"userId"];
            [dict setObject:toUser.userNick forKey:@"userNick"];
            [dict setObject:toUser.userAvatar forKey:@"userAvatar"];
            [dict setObject:toUser.userGender forKey:@"userGender"];
            [dict setObject:[NSString stringWithFormat:@"%d",toUser.userAge] forKey:@"userAge"];
            
        }
        
        [dict setObject:message.timeStamp forKey:@"send_time"];
        
        if(message.messageBodyType == eMessageBodyType_Voice){
            [dict setObject:@"[语音]" forKey:@"lastmsg"];
        }else if (message.messageBodyType ==eMessageBodyType_Image){
            [dict setObject:@"[图片]" forKey:@"lastmsg"];
        }else if (message.messageBodyType == eMessageBodyType_File){
            [dict setObject:@"[文件]" forKey:@"lastmsg"];
        }else{
            [dict setObject:message.textMessage.fileData forKey:@"lastmsg"];
        }
        
        if (count == 0) {
            [db executeUpdate:@"insert into nexfi_chat_user(userId,userAvatar,userNick,userGender,userAge,send_time,lastmsg,unreadnum) values(:userId, :userAvatar, :userNick, :userGender, :userAge, :send_time, :lastmsg, 0)"withParameterDictionary:dict];
        }else{
            [db executeUpdate:@"update nexfi_chat_user set userNick=:userNick,userAvatar=:userAvatar,userGender=:userGender,userAge=:userAge,send_time=:send_time,lastmsg=:lastmsg where userId=:userId"withParameterDictionary:dict];
            
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
#pragma -mark 清空单聊未读消息
- (void)clearMsgOfSingleWithmsg_id:(NSString *)msg_id{
    if ([db open]) {
        if ([db executeUpdate:@"update nexfi_chat set isRead = 1 where msg_id=?",msg_id]) {
            NSLog(@"清空单聊未读消息成功");
        }
    }
}
#pragma -mark 清空总群未读消息
- (void)clearMsgOfAllUserWithMsgId:(NSString *)msgId {
    if ([db open]) {
        if ([db executeUpdate:@"update nexfi_allUser_chat set isRead = 1 where msg_id=?",msgId]) {
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
#pragma -mark 查询总群聊所有的时间
- (NSMutableArray *)getAlltimeStamps{
    NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    if ([db open]) {
        
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat"];
        
        while ([rs next]) {
            
            
            NSString *timeStamps = [rs stringForColumn:@"send_time"];
            
            [chatList addObject:timeStamps];
            
        }
        
    }
    [chatList addObject:@"1"];
    return chatList;
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
    [chatList addObject:@"1"];
    return chatList;
    
}
#pragma -mark 查询总群聊的历史纪录
- (NSMutableArray *)getAllChatListWithNum:(NSInteger)num{
    
    NSMutableArray *chatList = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([db open]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        
        //
        [dic setObject:[NSString stringWithFormat:@"%ld",num] forKey:@"startNum"];
        [dic setObject:[NSString stringWithFormat:@"%d",20] forKey:@"endNum"];
        
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat order by send_time desc limit :startNum,:endNum"withParameterDictionary:dic];
//        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat order by send_time asc"];
        
        while ([rs next]) {
            
            TribeMessage *message = [[TribeMessage alloc]init];
            
            if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Text) {
                TextMessage *textMessage = [[TextMessage alloc]init];
                textMessage.fileData = [rs stringForColumn:@"msg_text"];
                textMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                message.textMessage = textMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Image){
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                message.fileMessage = fileMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Voice){
                VoiceMessage *voiceMessage = [[VoiceMessage alloc]init];
                voiceMessage.fileData = [rs stringForColumn:@"msg_text"];
                voiceMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                voiceMessage.durational = [NSString stringWithFormat:@"%d",[rs intForColumn:@"durational"]];
                voiceMessage.fileName = [rs stringForColumn:@"fileName"];
                voiceMessage.fileSize = [rs stringForColumn:@"fileSize"];
                voiceMessage.fileType = [rs stringForColumn:@"fileSufType"];
                message.voiceMessage = voiceMessage;
            }else{
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                fileMessage.filePath = [rs stringForColumn:@"filePath"];
                message.fileMessage = fileMessage;
            }
            UserModel *user = [[UserModel alloc]init];
            user.userId = [rs stringForColumn:@"userId"];
            user.userAvatar = [rs stringForColumn:@"userAvatar"];
            user.userNick = [rs stringForColumn:@"userNick"];
            user.userAge = [[rs stringForColumn:@"userAge"] intValue];
            user.userGender = [rs stringForColumn:@"userGender"];
            message.userMessage = user;
            
            message.timeStamp = [rs stringForColumn:@"send_time"];
            message.msgId = [rs stringForColumn:@"msg_id"];
            message.messageBodyType = [[rs stringForColumn:@"filetype"] intValue];
            
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
            
            if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Text) {
                TextMessage *textMessage = [[TextMessage alloc]init];
                textMessage.fileData = [rs stringForColumn:@"msg_text"];
                textMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                message.textMessage = textMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Image){
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                message.fileMessage = fileMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Voice){
                VoiceMessage *voiceMessage = [[VoiceMessage alloc]init];
                voiceMessage.fileData = [rs stringForColumn:@"msg_text"];
                voiceMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                voiceMessage.durational = [NSString stringWithFormat:@"%d",[rs intForColumn:@"durational"]];
                voiceMessage.fileName = [rs stringForColumn:@"fileName"];
                voiceMessage.fileSize = [rs stringForColumn:@"fileSize"];
                voiceMessage.fileType = [rs stringForColumn:@"fileSufType"];
                message.voiceMessage = voiceMessage;
            }else{
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                fileMessage.filePath = [rs stringForColumn:@"filePath"];
                message.fileMessage = fileMessage;
            }
            
            
            UserModel *user = [[UserModel alloc]init];
            user.userId = [rs stringForColumn:@"userId"];
            user.userAvatar = [rs stringForColumn:@"userAvatar"];
            user.userNick = [rs stringForColumn:@"userNick"];
            user.userAge = [[rs stringForColumn:@"userAge"] intValue];
            user.userGender = [rs stringForColumn:@"userGender"];
            message.userMessage = user;
            
            message.timeStamp = [rs stringForColumn:@"send_time"];
            message.msgId = [rs stringForColumn:@"msg_id"];
            message.messageBodyType = [[rs stringForColumn:@"filetype"] intValue];
            
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
        [dict setObject:[NSString stringWithFormat: @"%ld", num] forKey:@"page"];//page
        [dict setObject:[NSString stringWithFormat: @"%d", 20] forKey:@"pageNum"];//pageNum
        NSLog(@"dict====%@",dict);
        //        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat where from_user_id=:from_user_id or to_user_id=:to_user_id order by send_time asc limit :startNum,:endNum" withParameterDictionary:dict];
        
        /*
         xists nexfi_chat (from_user_id text, to_user_id text,send_time text,msg_text text,msg_id text,filetype text,durational integer,isRead integer)"];
         
         */
        
        //FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat where from_user_id=:from_user_id or to_user_id=:to_user_id order by send_time asc" withParameterDictionary:dict];
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat where (from_user_id=:from_user_id or to_user_id=:to_user_id) order by send_time desc limit :page,:pageNum" withParameterDictionary:dict];
        
        FMResultSet *ss = [db executeQuery:@"select * from nexfi_chat where (from_user_id=:from_user_id or to_user_id=:to_user_id) limit :page,:pageNum" withParameterDictionary:dict];        while ([ss next]) {
            NSLog(@"11111");
        }
        //FMResultSet *rs  = [db executeQuery:[NSString stringWithFormat:@"select * from letmedo_chat where from_user_id=%@ or to_user_id=%@ order by public_time desc limit :startNum,:endNum",fromId,toId]];
        
        
        PersonMessage * msg;
        while ([rs next]){
            NSLog(@"dad");
            
            msg = [[PersonMessage alloc] init];
            UserModel *user = [[UserModel alloc]init];
            user.userId = [rs stringForColumn:@"from_user_id"];
            msg.userMessage = user;
            
            msg.receiver = [rs stringForColumn:@"to_user_id"];
            msg.msgId = [rs stringForColumn:@"msg_id"];
            
            if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Text) {
                TextMessage *textMessage = [[TextMessage alloc]init];
                textMessage.fileData = [rs stringForColumn:@"msg_text"];
                textMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                msg.textMessage = textMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Image){
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                msg.fileMessage = fileMessage;
            }else if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_Voice){
                VoiceMessage *voiceMessage = [[VoiceMessage alloc]init];
                voiceMessage.fileData = [rs stringForColumn:@"msg_text"];
                voiceMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                voiceMessage.durational = [NSString stringWithFormat:@"%d",[rs intForColumn:@"durational"]];
                voiceMessage.fileName = [rs stringForColumn:@"fileName"];
                voiceMessage.fileSize = [rs stringForColumn:@"fileSize"];
                voiceMessage.fileType = [rs stringForColumn:@"fileSufType"];
                msg.voiceMessage = voiceMessage;
            }else{
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [rs stringForColumn:@"msg_text"];
                fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
                fileMessage.fileName = [rs stringForColumn:@"fileName"];
                fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
                fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
                fileMessage.filePath = [rs stringForColumn:@"filePath"];
                msg.fileMessage = fileMessage;
            }
            
            
            msg.timeStamp = [rs stringForColumn:@"send_time"];
            msg.messageBodyType = [[rs stringForColumn:@"filetype"] intValue];
            
            [recordArray addObject: msg];
        }
        [rs close];
        
        //[db close];
    }
    return recordArray;
}
#pragma -mark 获取单聊所有文件模型
- (NSMutableArray *)getAllFileFromSingleChat{
    NSMutableArray *allFileList = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat"];
        while ([rs next]) {
            if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_File && [[rs stringForColumn:@"filePath"] rangeOfString:@"nexfiFile/"].length > 0) {
                FileModel *file = [[FileModel alloc]init];
                file.fileName = [rs stringForColumn:@"fileName"];
                file.fileType = [rs stringForColumn:@"fileSufType"];
                file.partPath = [rs stringForColumn:@"filePath"];
                file.fileSize = [rs stringForColumn:@"fileSize"];
                file.fileData = [rs stringForColumn:@"msg_text"];
                [allFileList addObject:file];
            }
        }
    }
    
    return allFileList;
}
#pragma -mark 获取群聊所有文件模型
- (NSMutableArray *)getAllFileFromAllUserChat{
    NSMutableArray *allFileList = [[NSMutableArray alloc]initWithCapacity:0];
    //create table if not exists nexfi_allUser_chat (userId text ,userAvatar text , userNick text, userAge text, userGender text, send_time text, msg_text text, msg_id text , filetype text , fileName text,fileSize text,fileSufType text, filePath text, durational interger, isRead interger)
    /*
     fileMessage.fileData = [rs stringForColumn:@"msg_text"];
     fileMessage.isRead = [NSString stringWithFormat:@"%d",[rs intForColumn:@"isRead"]];
     fileMessage.fileName = [rs stringForColumn:@"fileName"];
     fileMessage.fileSize = [rs stringForColumn:@"fileSize"];
     fileMessage.fileType = [rs stringForColumn:@"fileSufType"];
     fileMessage.filePath = [rs stringForColumn:@"filePath"];
     */
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_allUser_chat"];
        while ([rs next]) {
            if ([[rs stringForColumn:@"filetype"] intValue] == eMessageBodyType_File && [[rs stringForColumn:@"filePath"] rangeOfString:@"nexfiFile/"].length > 0) {
                FileModel *file = [[FileModel alloc]init];
                file.fileName = [rs stringForColumn:@"fileName"];
                file.fileType = [rs stringForColumn:@"fileSufType"];
                file.partPath = [rs stringForColumn:@"filePath"];
                file.fileSize = [rs stringForColumn:@"fileSize"];
                file.fileData = [rs stringForColumn:@"msg_text"];
                [allFileList addObject:file];
            }
        }
    }
    
    return allFileList;
}
#pragma -mark 取出拷贝文件数据
- (NSMutableArray *)getCopyFileData{
    NSMutableArray *allFileList = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_file"];
        while ([rs next]) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [rs stringForColumn:@"fileName"];
            file.fileAbsolutePath = [rs stringForColumn:@"fileAbosolutePath"];
            file.partPath = [rs stringForColumn:@"partPath"];
            file.fileType = [rs stringForColumn:@"fileType"];
            file.fileSize = [rs stringForColumn:@"fileSize"];
            file.fileData = [rs stringForColumn:@"fileData"];
            file.fileKind = [rs stringForColumn:@"fileKind"];
            
            [allFileList addObject:file];
        }
    }
    
    return allFileList;
}
#pragma -mark 删除拷贝的某个文件
- (void)deleteCopyFile:(FileModel *)file{
    if ([db open]) {
        if ([db executeUpdate:@"delete from nexfi_file where fileName= ?",file.fileName]) {
            NSLog(@"删除某个文件数据成功");
        }
    }
}
#pragma -mark 获取所有聊天名单
- (NSMutableArray *)getAllChatUserList{
    NSMutableArray *allUser = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat_user order by send_time desc"];
        UserModel *user = [[UserModel alloc]init];;
        while ([rs next]) {
            
            user.userId = [rs stringForColumn:@"userId"];
            user.userNick = [rs stringForColumn:@"userNick"];
            user.userAvatar = [rs stringForColumn:@"userAvatar"];
            user.userAge = [[rs stringForColumn:@"userAge"] intValue];
            user.userGender = [rs stringForColumn:@"userGender"];
            
            [allUser addObject:user];
        }
    }
    
    return allUser;
}
#pragma -mark 查询聊天好友信息
- (UserModel *)getChatUserInfo:(NSString *)userId{
    UserModel *user = [[UserModel alloc]init];
    
    FMResultSet *rs = [db executeQuery:@"select * from nexfi_chat_user where userId = %@",userId];
    
    /*
     userId text , userAvatar text, userNick text , userAge text, userGender text, send_time text,lastmsg text, unreadnum integer default 0
     
     */
    
    while ([rs next]) {
        user.userId = [rs stringForColumn:@"userId"];
        user.userNick = [rs stringForColumn:@"userNick"];
        user.userAvatar = [rs stringForColumn:@"userAvatar"];
        user.userAge = [[rs stringForColumn:@"userAge"] intValue];
        user.userGender = [rs stringForColumn:@"userGender"];
        
    }
    
    return user;
    
}
@end
