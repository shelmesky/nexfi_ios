//
//  TextMessage.h
//  Nexfi
//
//  Created by fyc on 16/5/23.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextMessage : NSObject

@property (nonatomic, retain) NSString *fileData;
@property (nonatomic, retain) NSString *isRead;//0未读 1已读

@end
