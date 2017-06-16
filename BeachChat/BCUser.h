//
//  BCUser.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <FirebaseAuth/FirebaseAuth.h>
#import "BCFriendRequest.h"
#import "BCObject.h"

@interface BCUser : BCObject<BCObject>
@property (nonatomic, copy) NSString *identity;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy, readonly) NSString *validKey;
@property (nonatomic, assign) BCFriendRequestState state;

-(instancetype)initWithIdentity:(NSString*)identity andDisplayName:(NSString *)displayName;
-(NSDictionary *)json;
+(BCUser *)convertedToUserFromJSON:(FIRDataSnapshot *)snapshot;
+(NSArray<BCUser *>*)convertedToUsersFromJSONs:(FIRDataSnapshot *)snapshot;
+(NSString *)validKeyFromIdentity:(NSString *)identity;
@end
