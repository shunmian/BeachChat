//
//  BCChatManager.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChatManager.h"


@interface BCChatManager()
@property (nonatomic, strong,readwrite) BCUser *bcUser;
@end

@implementation BCChatManager

+(instancetype)sharedManager{
    static BCChatManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BCChatManager alloc] init];
        
        [_sharedManager getUsersWithCompletion:^(NSArray *users) {
            _sharedManager.users = [users mutableCopy];
        }];
        
        [_sharedManager getFriendsWithCompletion:^(NSArray *friends) {
            _sharedManager.friends = [friends mutableCopy];
        }];
        
        [_sharedManager bcUser];
//        [_sharedManager getFriendRequestsWithCompletion:^(NSArray *friendRequests) {
//            _sharedManager.friendRequests = [friendRequests mutableCopy];
//        }];
    });
    return _sharedManager;
}

-(BCUser *)bcUser{
    if(!_bcUser){
        _bcUser = [self.firUser convertToBCUser];
    }
    return _bcUser;
}

-(FIRDatabaseReference *)channelRef{
    if(!_channelRef){
        _channelRef = [[[[FIRDatabase database] reference] child:@"channels"] child:self.bcUser.validKey];
    }
    return _channelRef;
}

-(FIRDatabaseReference *)userRef{
    if(!_userRef){
        _userRef = [[[FIRDatabase database] reference] child:@"users"];
    }
    return _userRef;
}

-(FIRDatabaseReference *)messageRef{
    if(!_messageRef){
        _messageRef = [[[FIRDatabase database] reference] child:@"messages"];
    }
    return _messageRef;
}

-(FIRDatabaseReference *)friendRef{
    if(!_friendRef){
        _friendRef = [[[[FIRDatabase database] reference] child:@"friends"] child: _bcUser.validKey];
    }
    return _friendRef;
}

-(FIRDatabaseReference *)friendRequestRef{
    if(!_friendRequestRef){
        _friendRequestRef = [[[[FIRDatabase database] reference] child:@"friendRequests"] child:self.bcUser.validKey];
    }
    return _friendRequestRef;
}

-(FIRDatabaseReference *)timeRef{
    if(!_timeRef){
        _timeRef = [[[FIRDatabase database] reference] child:@"time"];
    }
    return _timeRef;
}

#pragma mark - channels
/*
-(void)observeChannelsWithEventType:(FIRDataEventType)eventType completion:(observeCompletion)completion{
    [self.channelRef observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        switch (eventType) {
            case FIRDataEventTypeChildAdded:{
                NSDictionary *channelDict = snapshot.value;
                NSString *identity = channelDict[@"identity"];
                NSString *displayName = channelDict[@"displayName"];
                BCChannel *channelAdded = [[BCChannel alloc] initWithIdentity:identity andDisplayName:displayName];
                [self.channels addObject:channelAdded];
                break;
            }
            default:
                break;
        }
        completion(self.channels);
    }];
}
 */

-(void)createChannel:(BCChannel *)channel{
    FIRDatabaseReference *addedChannelRef = [self.channelRef childByAutoId];
    [addedChannelRef setValue:[channel json]];
}


#pragma mark - users

-(void)observeUsersWithEventType:(FIRDataEventType)eventType completion:(observeCompletion)completion{
    [self.userRef observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        switch (eventType) {
            case FIRDataEventTypeChildAdded:{
                NSDictionary *userDict = snapshot.value;
                NSString *identity = userDict[@"identity"];
                NSString *displayName = userDict[@"displayName"];
                BCUser *userAdded = [[BCUser alloc] initWithIdentity:identity andDisplayName:displayName];
                [self.users addObject:userAdded];
                break;
            }
            default:
                break;
        }
        completion(self.users);
    }];
}

-(void)createUser:(BCUser *)user{
    NSLog(@"user.identiy:%@",user.identity);
    FIRDatabaseReference *addedUserRef = [self.userRef child:user.validKey];
    [addedUserRef setValue:[user json]];
}

-(void)getUsersWithCompletion:(observeCompletion)completion{
    NSMutableArray *users = [NSMutableArray array];
    [self.userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *item in snapshot.children.allObjects){
            NSDictionary *itemDict = item.value;
            BCUser *user = [[BCUser alloc] initWithIdentity:itemDict[@"identity"] andDisplayName:itemDict[@"displayName"]];
            [users addObject:user];
        }
        completion([NSArray arrayWithArray:users]);
    }];
}

-(void)getUserWithIdentity:(NSString *)identity withCompletion:(void(^)(BCUser *user, NSError *error))completion{
    FIRDatabaseReference *ref = [self.userRef child:[BCUser validKeyFromIdentity:identity]];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot.children.allObjects.count == 0){
            NSError *error = [NSError errorWithDomain:nil code:0 userInfo:nil];
            completion(nil,error);
        }else{
            NSDictionary *userDict = snapshot.value;
            BCUser *user = [[BCUser alloc] initWithIdentity:identity andDisplayName:userDict[@"displayName"]];
            completion(user,nil);
        }
    }];
}

#pragma mark - messages

-(void)observeMessagesWithEventType:(FIRDataEventType)eventType completion:(observeCompletion)completion{
    [self.messageRef observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        switch (eventType) {
            case FIRDataEventTypeChildAdded:{
                NSDictionary *messageDict = snapshot.value;
                NSString *identity = messageDict[@"identity"];
                NSString *displayName = messageDict[@"displayName"];
                BCUser *userAdded = [[BCUser alloc] initWithIdentity:identity andDisplayName:displayName];
                [self.users addObject:userAdded];
                break;
            }
            default:
                break;
        }
        completion(self.users);
    }];
}

-(void)createMessage:(BCMessage *)message{
    FIRDatabaseReference *addedMessageRef = [self.messageRef childByAutoId];
    [addedMessageRef setValue:[message json]];
}

#pragma mark - friends

-(void)observeFriendsWithEventType:(FIRDataEventType)eventType completion:(observeCompletion)completion{
    [self.friendRef observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        switch (eventType) {
            case FIRDataEventTypeChildAdded:{
                NSDictionary *messageDict = snapshot.value;
                NSString *identity = messageDict[@"identity"];
                NSString *displayName = messageDict[@"displayName"];
                BCUser *userAdded = [[BCUser alloc] initWithIdentity:identity andDisplayName:displayName];
                [self.friends addObject:userAdded];
                break;
            }
            default:
                break;
        }
        completion(self.friends);
    }];
}

-(void)addFriend:(BCUser *)user{
    FIRDatabaseReference *addedFriendRef = [self.friendRef childByAutoId];
    [addedFriendRef setValue:[user json]];
}

-(void)getFriendsWithCompletion:(observeCompletion)completion{
    NSMutableArray *friends = [NSMutableArray array];
    [self.userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *item in snapshot.children.allObjects){
            NSDictionary *itemDict = item.value;
            BCUser *user = [[BCUser alloc] initWithIdentity:itemDict[@"identity"] andDisplayName:itemDict[@"displayName"]];
            [friends addObject:user];
        }
        completion([NSArray arrayWithArray:friends]);
    }];
}

#pragma mark - friendsRequest
-(void)observeFriendsRequestWithEventType:(FIRDataEventType)eventType completion:(observeCompletion)completion{
    [self.friendRequestRef observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        switch (eventType) {
            case FIRDataEventTypeChildAdded:{
                NSDictionary *friendRequestDict = snapshot.value;
                NSDictionary *fromDict = friendRequestDict[@"from"];
                NSDictionary *toDict = friendRequestDict[@"to"];
                NSNumber *state = friendRequestDict[@"state"];
                
                BCUser *from = [[BCUser alloc] initWithIdentity:fromDict[@"identity"] andDisplayName:fromDict[@"displayName"]];
                
                BCUser *to = [[BCUser alloc] initWithIdentity:toDict[@"identity"] andDisplayName:toDict[@"displayName"]];
                
                BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to state:state.integerValue];
                [self.friendRequests addObject:friendRequest];
                break;
            }
            default:
                break;
        }
        completion(self.friendRequests);
    }];
}

-(void)addFriendRequestFrom:(BCUser *)from to:(BCUser *)to{
    
    BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to state:BCFriendRequestStateApplied];
    FIRDatabaseReference *addedFriendRequestRef = [self.friendRequestRef child:friendRequest.validKey];
    [addedFriendRequestRef setValue:[friendRequest json]];
}

-(void)deleteFriendRequestFrom:(BCUser *)from to:(BCUser *)to{
    BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to];
    FIRDatabaseReference *addedFriendRequestRef = [self.friendRequestRef child:friendRequest.validKey];
    [addedFriendRequestRef setValue:nil];
}

-(void)addFriendRequest:(BCFriendRequest *)friendRequest{
    friendRequest.state = BCFriendRequestStateApplied;
    NSDictionary *json = [friendRequest json];
    
    FIRDatabaseReference *fromRef = [friendRequest fromRef];
    [fromRef setValue:json];
    
    FIRDatabaseReference *toRef = [friendRequest toRef];
    [toRef setValue:json];
}

-(void)acceptFriendRequest:(BCFriendRequest *)friendRequest{
    FIRDatabaseReference *fromRef = [friendRequest fromRef];
    NSMutableDictionary *fromJson = [[friendRequest json] mutableCopy];
    [fromJson setValue:@(BCFriendRequestStateAccepted) forKey:@"state"];
    [fromRef setValue:fromJson];
    
    FIRDatabaseReference *toRef = [friendRequest toRef];
    NSMutableDictionary *toJson = [[friendRequest json] mutableCopy];
    [toJson setValue:@(BCFriendRequestStateAccepted) forKey:@"state"];
    [toRef setValue:toJson];
    
}

//-(void)getFriendRequestFrom:(BCUser *)from to:(BCUser *)to withCompletion:(void(^)(BCFriendRequest *,NSError *))completion{
//    BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to];
//    NSString *path = [NSString stringWithFormat:@"%@/%@",from.validKey, friendRequest.validKey];
//    FIRDatabaseReference *ref = [self.friendRef child:path];
//    ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        if(!snapshot){
//            NSError *error = [NSError errorWithDomain:nil code:0 userInfo:@{@"friednRequest",@"key not exist"}];
//            completion(nil,error);
//        }else{
//            NSDictionary *requestDict = snapshot.value;
//            BCUser *from = [[BCUser alloc] initWithIdentity:requestDict[@"to"][@"identity"] andDisplayName:requestDict[@"to"][@"displayName"]];
//            BCUser *to = [BCUser alloc] initWithIdentity:requestDict[@"from"] andDisplayName:<#(NSString *)#>
//                                                                                                                             ]
//            completion()
//        }
//    }
//
//
//}




-(void)getFriendRequestsWithCompletion:(observeCompletion)completion{
    NSMutableArray *friendRequests = [NSMutableArray array];
    [self.friendRequestRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *item in snapshot.children.allObjects){
            NSDictionary *friendRequestDict = item.value;
            NSDictionary *fromDict = friendRequestDict[@"from"];
            NSDictionary *toDict = friendRequestDict[@"to"];
            NSNumber *state = friendRequestDict[@"state"];
            
            BCUser *from = [[BCUser alloc] initWithIdentity:fromDict[@"identity"] andDisplayName:fromDict[@"displayName"]];
            
            BCUser *to = [[BCUser alloc] initWithIdentity:toDict[@"identity"] andDisplayName:toDict[@"displayName"]];
            
            BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to state:state.integerValue];
            
            [friendRequests addObject:friendRequest];
        }
        completion([NSArray arrayWithArray:friendRequests]);
    }];
}


//-(NSMutableArray *)getChannels{
//    NSMutableArray *users = [NSMutableArray array];
//    [self.userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        for(FIRDataSnapshot *item in snapshot.children.allObjects){
//            NSDictionary *itemDict = item.value;
//            BCUser *user = [[BCUser alloc] initWithIdentity:itemDict[@"identity"] andDisplayName:itemDict[@"displayName"]];
//            [users addObject:user];
//        }
//    }];
//    return users;
//}


@end
