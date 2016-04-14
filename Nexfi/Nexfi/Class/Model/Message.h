//
//  BaseMessage.h
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
/*!
 @enum
 @brief 聊天类型
 @constant eMessageType_SingleChat 单聊
 @constant eMessageType_AllUserChat 所有人
 @constant eMessageType_GroupChat 群聊
 @constant eMessageType_SendUserInfo 发送用户信息
 @constant eMessageType_requestUserInfo 请求用户信息

 */
typedef NS_ENUM(NSInteger, MessageType) {
    eMessageType_SingleChat = 1,
    eMessageType_AllUserChat = 2,
    eMessageType_GroupChat = 3,
    eMessageType_SendUserInfo = 4,
    eMessageType_requestUserInfo = 5

};

/**
 *  消息发送状态,自己发送的消息时有
 */
typedef NS_ENUM(NSUInteger, FNMessageSendState){
    eMessageSendSuccess = 0 /**< 消息发送成功 */,
    eMessageSendStateSending, /**< 消息发送中 */
    eMessageSendFail /**< 消息发送失败 */,
};

/*!
 @enum
 @brief 聊天内容类型
 @constant eMessageBodyType_Text 文本类型
 @constant eMessageBodyType_Image 图片类型
 @constant eMessageBodyType_Video 视频类型
 @constant eMessageBodyType_Location 位置类型
 @constant eMessageBodyType_Voice 语音类型
 @constant eMessageBodyType_File 文件类型
 @constant eMessageBodyType_Command 命令类型
 */
typedef NS_ENUM(NSInteger, MessageBodyType) {
    eMessageBodyType_Text = 1,
    eMessageBodyType_Image,
    eMessageBodyType_Video,
    eMessageBodyType_Location,
    eMessageBodyType_Voice,
    eMessageBodyType_File,
    eMessageBodyType_Command
};
#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, retain) NSString *timestamp;//发送时间
@property (nonatomic, retain) NSString *msgId;//消息id
@property (nonatomic, retain) NSString *sender;//发送此条消息的id
@property (nonatomic, retain) NSString *senderNickName;
@property (nonatomic, retain) NSString *senderFaceImageStr;
@property (nonatomic, assign) MessageBodyType fileType;//文件类型
@property (nonatomic, assign) MessageType messageType;
@property (nonatomic, retain) NSString *nodeId;




//@property (nonatomic, retain) NSString *content;//内容
//单聊@{receiver,personContent,durational,file}
//群聊@{isRead,TribeContent,durational,file,groupId}
//所有人@{isRead,TribeContent,durational,file}


//@property (nonatomic, retain) NSString *durational;//语音时间
//@property (nonatomic, retain) NSString *file;
//@property (nonatomic, retain) NSString *receiver;//接收者


@end
