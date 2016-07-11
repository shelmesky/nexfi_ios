//
//  UserModel.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)initWithaDic:(NSDictionary *)aDic{
    if (self = [super init]) {
        self.userId = aDic[@"userId"];
        self.userNick = aDic[@"userNick"];
        self.userGender = aDic[@"userGender"];
        self.userAge = [aDic[@"userAge"] intValue];
        self.nodeId = aDic[@"nodeId"];
        self.userAvatar = aDic[@"userAvatar"];
        self.phoneNumber = aDic[@"phoneNumber"];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.userNick = [aDecoder decodeObjectForKey:@"userNick"];
        self.userGender = [aDecoder decodeObjectForKey:@"userGender"];
        self.userAge = [[aDecoder decodeObjectForKey:@"userAge"] intValue];
        self.nodeId = [aDecoder decodeObjectForKey:@"nodeId"];
        self.userAvatar = [aDecoder decodeObjectForKey:@"userAvatar"];
        self.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.userNick forKey:@"userNick"];
    [aCoder encodeObject:self.userGender forKey:@"userGender"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%d",self.userAge] forKey:@"userAge"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.nodeId forKey:@"nodeId"];
    [aCoder encodeObject:self.userAvatar forKey:@"userAvatar"];
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"id：%@,昵称：%@,性别：%@,年龄：%d 图片: %@",self.userId,self.userNick,self.userGender,self.userAge,self.userAvatar];
}

@end
