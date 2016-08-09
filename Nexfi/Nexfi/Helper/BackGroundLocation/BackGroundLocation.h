//
//  BackGroundLocation.h
//  Nexfi
//
//  Created by fyc on 16/8/9.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BackGroundLocation : NSObject<CLLocationManagerDelegate>
- (void)startLocation ;
@end
