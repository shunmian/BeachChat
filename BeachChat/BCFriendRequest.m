//
//  BCFriendRequest.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCFriendRequest.h"

@interface BCFriendRequest()
@property (nonatomic, strong, readwrite) NSString *validKey;
@end

@implementation BCFriendRequest

-(instancetype)initWithFrom:(BCUser *)from to:(BCUser *)to state:(BCFriendRequestState)state{
    if(self = [super init]){
        _from = from;
        _to = to;
        _state = state;
        NSString *toUserKey = _to.validKey;
        NSString *fromUserKey = _from.validKey;
        NSString *combinedKey;
        NSComparisonResult compareResult = [fromUserKey compare:toUserKey];
        if(compareResult == NSOrderedAscending){
            combinedKey = [NSString stringWithFormat:@"%@&vs&%@",fromUserKey,toUserKey];
        }else{
            combinedKey = [NSString stringWithFormat:@"%@&vs&%@",toUserKey,fromUserKey];
        }
        _validKey = combinedKey;
    }
    return self;
}

-(instancetype)initWithFrom:(BCUser *)from to:(BCUser *)to{
    if(self = [self initWithFrom:from to:to state:BCFriendRequestStateNoteApplied]){
    
    }
    return self;
}

-(NSDictionary *)json{
    NSDictionary *dict = @{@"from":[self.from json],
                           @"to":[self.to json],
                           @"state":@(self.state)};
    return dict;
}

+(NSString *)validKeyFrom:(BCUser *)from to:(BCUser *)to{
    NSString *toUserKey = to.validKey;
    NSString *fromUserKey = from.validKey;
    NSString *combinedKey;
    NSComparisonResult compareResult = [fromUserKey compare:toUserKey];
    if(compareResult == NSOrderedAscending){
        combinedKey = [NSString stringWithFormat:@"%@&vs&%@",fromUserKey,toUserKey];
    }else{
        combinedKey = [NSString stringWithFormat:@"%@&vs&%@",toUserKey,fromUserKey];
    }
    return combinedKey;
}

-(FIRDatabaseReference *)toRef{
    NSString *path = [NSString stringWithFormat:@"friendRequests/%@/%@",self.to.validKey,self.validKey];
    return [[[FIRDatabase database] reference] child:path];
}

-(FIRDatabaseReference *)fromRef{
        NSString *path = [NSString stringWithFormat:@"friendRequests/%@/%@",self.from.validKey,self.validKey];
    return [[[FIRDatabase database] reference] child:path];
}

-(BCUser *)otherOf:(BCUser *)one{
    if([one.validKey isEqualToString:self.to.validKey]){
        return self.from;
    }else if([one.validKey isEqualToString:self.from.validKey]){
        return self.to;
    }else{
        return nil;
    }
}

-(BOOL)isSender:(BCUser *)user{
    if([user.validKey isEqualToString:self.from.validKey]){
        return YES;
    }else {
        return NO;
    }
}

+(BCFriendRequest *)convertedFromJSON:(FIRDataSnapshot *)snapshot{
    BCUser *fromUser = [BCUser convertedFromJSON:[snapshot childSnapshotForPath:@"from"]];
    BCUser *toUser = [BCUser convertedFromJSON:[snapshot childSnapshotForPath:@"to"]];
    BCFriendRequestState state = ((NSNumber *)[snapshot childSnapshotForPath:@"state"].value).integerValue;
    return [[BCFriendRequest alloc] initWithFrom:fromUser to:toUser state:state];
}

+(NSArray <BCFriendRequest *>*)convertedToFriendRequestsFromJSONs:(FIRDataSnapshot *)snapshot receiver:(BCUser *)receiver{
    NSMutableArray *requests = [NSMutableArray new];
    for(FIRDataSnapshot *item in snapshot.children){
        BCFriendRequest *request = [BCFriendRequest convertedFromJSON:item];
        if(receiver && [request.to.validKey isEqualToString:receiver.validKey] && (request.state == BCFriendRequestStateApplied)){
            [requests addObject:request];
        }
    }
    return [NSArray arrayWithArray:requests];
}


+(NSArray <BCUser *>*)convertedToFriendsFromJSONs:(FIRDataSnapshot *)snapshot user:(BCUser *)user{
    NSMutableArray *friends = [NSMutableArray new];
    NSAssert(user, @"user must be non nil");
    for(FIRDataSnapshot *item in snapshot.children){
        BCFriendRequest *request = [BCFriendRequest convertedFromJSON:item];
        if(request.state == BCFriendRequestStateAccepted){
            BCUser *friend = [request otherOf:user];
            [friends addObject:friend];
        }
    }
    return [NSArray arrayWithArray:friends];
}



/*
+(NSArray <BCFriendRequest *>*)convertedFromJSONs:(FIRDataSnapshot *)snapshot to:(BCUser *)user{
    return [BCFriendRequest convertedFromJSONs:snapshot to:user withState:BCFriendRequestStateNoteApplied];

}

+(NSArray <BCFriendRequest *>*)convertedFromJSONs:(FIRDataSnapshot *)snapshot{
    return [BCFriendRequest convertedFromJSONs:snapshot to:nil];
}
 */

@end
