//
//  SqlManager.h
//


//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "Message.h"

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
@interface SqlManager : NSObject
- (void)creatTable;
+ (SqlManager *)shareInstance;

//获取未读消息数
- (NSInteger)getUnreadNumOfMsg;
//获取某人未读的消息个数
-(NSInteger)getUnreadMessageCount:(NSString *) user_id;
//插入某人－》某人数据
- (void)add_chatUser:(UserModel*)User WithTo_user:(UserModel *)toUser WithMsg:(Message *)message;
//更新用户聊天信息
- (void)update_chat_to_user:(UserModel *)toUser WithMsg:(Message *)message;
//增加未读消息
-(void)addUnreadNum:(NSString*)user_id;
//清空未读消息
-(void)clearUnreadNum:(NSString*)user_id;
//删除联系人的聊天记录
-(void)deleteTalk:(NSString *)user_id;
//删除所有聊天的记录
- (void)deleteAllTalk;
//查询聊天历史记录
-(NSMutableArray *)getChatHistory:(NSString *) fromId withToId:(NSString *) toId withStartNum:(NSInteger) num;
//获取所有聊天名单
- (NSMutableArray *)getAllChatUserList;
//查询聊天好友信息
- (UserModel *)getChatUserInfo:(NSString *)userId;
@end
