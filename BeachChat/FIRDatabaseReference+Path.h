//
//  FIRDatabaseReference+Path.h
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <FirebaseDatabase/FirebaseDatabase.h>
#import "BCUser.h"


typedef NS_ENUM(NSUInteger,BCRefSection){
    BCRefUsersSection = 0,
    BCRefFriendsSection,
    BCRefFriendRequestsSection,
    BCRefChannelsSection,
    BCRefMessagesSection,
};

typedef FIRDatabaseReference*(^BCPathSectionBlock)(BCRefSection sect);
typedef FIRDatabaseReference*(^BCPathUserBlock)(BCUser *user);
typedef FIRDatabaseReference*(^BCPathItemBlock)(BCObject *item);
typedef FIRDatabaseReference*(^BCPathChildBlock)(NSString *path);

@interface FIRDatabaseReference (Path)
@property(nonatomic, strong, readonly) BCPathSectionBlock section;
@property(nonatomic, strong, readonly) BCPathUserBlock user;
@property(nonatomic, strong, readonly) BCPathItemBlock item;
@property(nonatomic, strong, readonly) BCPathChildBlock child;
+(FIRDatabaseReference *)root;
@end
