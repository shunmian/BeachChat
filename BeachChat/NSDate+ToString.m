//
//  NSDate+ToString.m
//  BeachChat
//
//  Created by LAL on 2017/6/19.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "NSDate+ToString.h"

@implementation NSDate (ToString)



-(NSString *)toString{
    NSString *dateString;
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    
    NSDateComponents *selfComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    
    if(currentComponents.year == selfComponents.year &&
             currentComponents.month == selfComponents.month &&
             currentComponents.day - selfComponents.day == 1){
        formatter.dateFormat = @"HH:mm";
        dateString = [NSString stringWithFormat:@"昨天 %@",[formatter stringFromDate:self]];
    }else if(currentComponents.year == selfComponents.year &&
           currentComponents.month == selfComponents.month &&
           currentComponents.day == selfComponents.day){
        formatter.dateFormat = @"HH:mm";
        dateString = [NSString stringWithFormat:@"今天 %@",[formatter stringFromDate:self]];
    }else{
        formatter.dateFormat = @"yyyy-MM-dd";
        dateString = [formatter stringFromDate:self];
    }
    return dateString;
}

+(NSDate *)convertedToDateFromTimeInterval:(NSTimeInterval)timeInterval{
    return  [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
}

+(NSString *)toStringFromTimeInterval:(NSTimeInterval)timeInterval{
    NSDate *date = [NSDate convertedToDateFromTimeInterval:timeInterval];
    return [date toString];
}


+(void)getDateWithCompletion:(void(^)(NSDate *date, NSError *error))completion{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [ref updateChildValues:@{@"timeStamp":[FIRServerValue timestamp]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            [[ref child:@"timeStamp" ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSNumber *timeInterval = snapshot.value;
                NSTimeInterval t = timeInterval.integerValue;
                NSDate *localDate = [NSDate convertedToDateFromTimeInterval:t];
                completion(localDate,nil);
            }];
        }else{
            NSLog(@"error:%@",error.localizedDescription);
            completion(nil,error);
        }
    }];
}


@end
