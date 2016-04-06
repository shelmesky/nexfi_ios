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
@property (nonatomic, retain) NSString *userHead;//

- (id)initWithaDic:(NSDictionary *)aDic;

@end
