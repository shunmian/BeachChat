//
//  BCDate.h
//  
//
//  Created by LAL on 2017/6/14.
//
//

#import <Foundation/Foundation.h>

@interface BCDate : NSObject

+(void)getDateWithCompletion:(void(^)(NSDate *date, NSError *error))completion;
+(NSDate *)convertToLoalTimeZone:(NSDate *)date;
@end
