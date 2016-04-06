//
//  SqlManager.h
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
@interface SqlManager : NSObject
- (void)creatTable;
+ (SqlManager *)shareInstance;
@end
