//
//  FIRDatabaseReference+Path.m
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "FIRDatabaseReference+Path.h"

@implementation FIRDatabaseReference (Path)

+(FIRDatabaseReference *)root{
    return [[FIRDatabase database] reference];
}

-(BCPathSectionBlock)section{
    return ^FIRDatabaseReference *(BCRefSection sect){
        NSString *sectStr;
        switch (sect) {
            case BCRefUsersSection:
                sectStr = @"users";
                break;
            case BCRefFriendsSection:
                sectStr = @"friends";
                break;
            case BCRefFriendRequestsSection:
                sectStr = @"friendRequests";
                break;
            case BCRefChannelsSection:
                sectStr = @"channels";
                break;
            case BCRefMessagesSection:
                sectStr = @"messages";
                break;
            default:
                break;
        }
        return [self child:sectStr];
    };
}

-(BCPathUserBlock)user{
    return ^FIRDatabaseReference*(BCUser *user){
        return [self child:user.validKey];
    };
}

-(BCPathItemBlock)item{
    return ^FIRDatabaseReference*(id<BCObject> item){
        return [self child:item.validKey];
    };
}

-(BCPathChildBlock)child{
    return ^FIRDatabaseReference*(NSString *path){
        return [self child:path];
    };
}


@end
