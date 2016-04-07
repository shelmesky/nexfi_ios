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
        self.userName = aDic[@"userName"];
        self.sex = aDic[@"sex"];
        self.userHead = aDic[@"userHead"];
        self.age = aDic[@"age"];
        self.birthday = aDic[@"birthday"];
        self.headImg = aDic[@"headImg"];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.userHead = [aDecoder decodeObjectForKey:@"userHead"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.age = [aDecoder decodeObjectForKey:@"age"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.userHead forKey:@"userHead"];
    [aCoder encodeObject:self.age forKey:@"age"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"id：%@,昵称：%@,性别：%@,生日：%@,年龄：%@",self.userId,self.userName,self.sex,self.birthday,self.age];
}

@end
