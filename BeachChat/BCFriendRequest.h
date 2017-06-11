//
//  BCFriendRequest.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCUser;
typedef NS_ENUM(NSUInteger,BCFriendRequestState){
    BCFriendRequestStateNoteApplied = 0,
    BCFriendRequestStateApplied,
    BCFriendRequestStateAccepted,
    BCFriendRequestStateBeingApplied,//to be continue
    BCFriendRequestStateFinished,
};

@interface BCFriendRequest : NSObject

@property (nonatomic, strong) BCUser *from;
@property (nonatomic, strong) BCUser *to;
@property (nonatomic, assign) BCFriendRequestState state;
@property (nonatomic, strong, readonly) NSString *validKey;

-(instancetype)initWithFrom:(BCUser *)from to:(BCUser *)to;
-(instancetype)initWithFrom:(BCUser *)from to:(BCUser *)to state:(BCFriendRequestState)state;
-(NSDictionary *)json;
+(NSString *)validKeyFrom:(BCUser *)from to:(BCUser *)to;

-(BCUser *)otherOf:(BCUser *)one;
-(BOOL)isSender:(BCUser *)user;

-(FIRDatabaseReference *)toRef;
-(FIRDatabaseReference *)fromRef;
+(BCFriendRequest *)convertedFromJSON:(FIRDataSnapshot *)snapshot;

/* return friendRequests from @"/friendRequests/user_validkey" that is sending to user with BCFriendRequestStateApplied.
 */
+(NSArray <BCFriendRequest *>*)convertedToFriendRequestsFromJSONs:(FIRDataSnapshot *)snapshot receiver:(BCUser *)receiver;
/* return user's friends from @"/friendRequests/user_validkey" where state is BCFriendRequestStateAccepted
 */
+(NSArray <BCUser *>*)convertedToFriendsFromJSONs:(FIRDataSnapshot *)snapshot user:(BCUser *)user;


@end
