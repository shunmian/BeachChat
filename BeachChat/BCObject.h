//
//  BCObject.h
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BCObject;
@protocol BCObject <NSObject>
@property(nonatomic, strong, readonly) NSString *validKey;
-(NSDictionary *)json;
+(BCObject *)convertedToUserFromJSON:(FIRDataSnapshot *)snapshot;
+(NSArray<BCObject *>*)convertedToUsersFromJSONs:(FIRDataSnapshot *)snapshot;
@end


@interface BCObject : NSObject

@end
