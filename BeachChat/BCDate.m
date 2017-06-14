//
//  BCDate.m
//  
//
//  Created by LAL on 2017/6/14.
//
//

#import "BCDate.h"

@implementation BCDate


+(void)getDateWithCompletion:(void(^)(NSDate *date, NSError *error))completion{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [ref updateChildValues:@{@"timeStamp":[FIRServerValue timestamp]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            [[ref child:@"timeStamp" ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSNumber *timeInterval = snapshot.value;
                NSTimeInterval t = timeInterval.integerValue;
                NSDate *sourceDate = [NSDate dateWithTimeIntervalSince1970:t/1000];
                NSDate *localDate = [BCDate convertToLoalTimeZone:sourceDate];
                completion(localDate,nil);
            }];
        }else{
            NSLog(@"error:%@",error.localizedDescription);
            completion(nil,error);
        }
    }];
}

+(NSDate *)convertToLoalTimeZone:(NSDate *)date{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSTimeInterval seconds = [localTimeZone secondsFromGMTForDate:date];
    NSDate *localDate = [NSDate dateWithTimeInterval:seconds sinceDate:date];
    return localDate;
}

@end
