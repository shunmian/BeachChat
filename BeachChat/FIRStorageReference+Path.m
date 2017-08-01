//
//  FIRStorageReference+Path.m
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "FIRStorageReference+Path.h"

@implementation FIRStorageReference (Path)

-(BCStoragePathSectionBlock)section{
    return ^FIRStorageReference *(BCRefSection sect){
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

-(BCStoragePathUserBlock)user{
    return ^FIRStorageReference*(BCUser *user){
        return [self child:user.validKey];
    };
}

-(BCStoragePathItemBlock)item{
    return ^FIRStorageReference*(id<BCObject> item){
        return [self child:item.validKey];
    };
}

-(BCStoragePathChildBlock)child{
    return ^FIRStorageReference*(NSString *path){
        return [self child:path];
    };
}
@end
