//
//  NFChatCacheFileUtil.h
//  Nexfi
//
//  Created by fyc on 16/4/8.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFChatCacheFileUtil : NSObject

+ (NFChatCacheFileUtil*)sharedInstance;

- (NSString*)userDocPath;
- (BOOL) deleteWithContentPath:(NSString *)thePath;
- (NSString*)chatCachePathWithFriendId:(NSString*)theFriendId andType:(NSInteger)theType;
- (void)deleteFriendChatCacheWithFriendId:(NSString*)theFriendId;
- (void)deleteAllFriendChatDoc;

@end
