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

typedef FIRDatabaseReference*(^BCJSONPathSectionBlock)(BCRefSection sect);
typedef FIRDatabaseReference*(^BCJSONPathUserBlock)(BCUser *user);
typedef FIRDatabaseReference*(^BCJSONPathItemBlock)(BCObject *item);
typedef FIRDatabaseReference*(^BCJSONPathChildBlock)(NSString *path);

@interface FIRDatabaseReference (Path)
@property(nonatomic, strong, readonly) BCJSONPathSectionBlock section;
@property(nonatomic, strong, readonly) BCJSONPathUserBlock user;
@property(nonatomic, strong, readonly) BCJSONPathItemBlock item;
@property(nonatomic, strong, readonly) BCJSONPathChildBlock child;

@end
