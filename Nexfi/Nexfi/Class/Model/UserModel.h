//
//  UserModel.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, retain) NSString *userId;//
@property (nonatomic, retain) NSString *userName;//
@property (nonatomic, retain) NSString *sex;//
@property (nonatomic, retain) NSData *userHead;//
@property (nonatomic, retain) NSString *age;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *headImg;

- (id)initWithaDic:(NSDictionary *)aDic;

@end
