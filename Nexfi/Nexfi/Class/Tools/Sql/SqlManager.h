//
//  SqlManager.h
//


//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "PersonMessage.h"
#import "Message.h"
#import "TribeMessage.h"
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
@interface SqlManager : NSObject
#pragma -mark 创建表
- (void)creatTable;
+ (SqlManager *)shareInstance;

#pragma -mark 获取所有人群聊的未读数
- (NSInteger)getUnreadNumOfAllUser_Chat;
#pragma -mark 获取群聊未读数
- (NSInteger)getUnreadNumOfGroup_chatWithGroupId:(NSString *)groupId;
#pragma -mark 获取未读消息数
- (NSInteger)getUnreadNumOfMsg;
#pragma -mark 获取未读的消息个数
-(NSInteger)getUnreadMessageCount:(NSString *) user_id;
#pragma -mark 插入总群聊数据
- (void)insertAllUser_ChatWith:(UserModel *)user WithMsg:(TribeMessage *)message;
#pragma -mark 插入群组消息
- (void)insertAllUser_ChatWith:(UserModel *)user WithMsg:(TribeMessage *)message WithGroupId:(NSString *)groupId;
#pragma -mark 插入某人－》某人数据
- (void)add_chatUser:(UserModel*)User WithTo_user:(UserModel *)toUser WithMsg:(PersonMessage *)message;
#pragma -mark 更新用户数据
- (void)update_chat_to_user:(UserModel *)toUser WithMsg:(PersonMessage *)message;
#pragma -mark 更新用户信息
- (void)updateUserHead:(UserModel *)userModel;
- (void)updateUserName:(UserModel *)userModel;
#pragma -mark 清空群组未读消息
- (void)clearMsgOfGroup:(NSString *)groupId;
#pragma -mark 清空单聊未读消息
- (void)clearMsgOfSingleWithmsg_id:(NSString *)msg_id;
#pragma -mark 清空总群未读消息
- (void)clearMsgOfAllUserWithMsgId:(NSString *)msgId;
#pragma -mark 增加未读消息
-(void)addUnreadNum:(NSString*)user_id;
#pragma -mark 清空未读消息
-(void)clearUnreadNum:(NSString*)user_id;
#pragma -mark 删除联系人的聊天记录
-(void)deleteTalk:(NSString *)user_id;
#pragma -mark 删除所有人的聊天记录
- (void)deleteAllTalk;
#pragma -mark 查询总群聊的所有msgId
- (NSMutableArray *)getAllChatMsgIdList;
#pragma -mark 查询总群聊的历史纪录
- (NSMutableArray *)getAllChatListWithNum:(NSInteger)num;
#pragma -mark 查询总群聊的历史纪录
- (NSMutableArray *)getGroupChatListWithNum:(NSInteger)num WithGroupId:(NSString *)groupId;
#pragma -mark 查询聊天历史纪录
-(NSMutableArray *)getChatHistory:(NSString *) fromId withToId:(NSString *) toId withStartNum:(NSInteger) num;
#pragma -mark 获取所有聊天名单
- (NSMutableArray *)getAllChatUserList;
#pragma -mark 查询聊天好友信息
- (UserModel *)getChatUserInfo:(NSString *)userId;

@end
