//
//  NSDate+ToString.h
//  BeachChat
//
//  Created by LAL on 2017/6/19.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ToString)
-(NSString *)toString;
+(NSString *)toStringFromTimeInterval:(NSTimeInterval)timeInterval;
+(NSDate *)convertedToDateFromTimeInterval:(NSTimeInterval)timeInterval;
+(void)getDateWithCompletion:(void(^)(NSDate *date, NSError *error))completion;
@end
