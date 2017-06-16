//
//  BCChatManager.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChatManager.h"
#import "FIRDatabaseReference+Path.h"

@interface BCChatManager()
@property (nonatomic, strong, readwrite) BCUser *bcUser;

#pragma mark - Ref
@property (nonatomic, strong, readwrite) FIRDatabaseReference *usersSectionRef;

@property (nonatomic, strong, readwrite) FIRDatabaseReference *channelsSectionRef;
@property (nonatomic, strong, readwrite) FIRDatabaseReference *channelsRef;

@property (nonatomic, strong, readwrite) FIRDatabaseReference *messagesSectionRef;
@property (nonatomic, strong, readwrite) FIRDatabaseReference *messagesRef;

@property (nonatomic, strong, readwrite) FIRDatabaseReference *friendsSectionRef;
@property (nonatomic, strong, readwrite) FIRDatabaseReference *friendsRef;

@property (nonatomic, strong, readwrite) FIRDatabaseReference *friendRequestsSectionRef;
@property (nonatomic, strong, readwrite) FIRDatabaseReference *friendRequestsRef;




@end

@implementation BCChatManager

#pragma mark - Life Cycle


-(void)setUpWithEntryData:(id)data{
    NSAssert([data isKindOfClass:[FIRUser class]], @"data must be FIRUser class");
    self.firUser = (FIRUser *)data;
}

-(void)setUpSignals{
    RAC(self,channels) = [self createChannelsSignal];
    RAC(self,users) = [self createUsersSignal];
    RAC(self,friends) = [self createFriendsSignal];
    RAC(self,friendRequests) = [self createFriendRequestsSignal];
}

+(instancetype)sharedManager{
    static BCChatManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BCChatManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - 0 level setter & getter

-(BCUser *)bcUser{
    if(!_bcUser){
        _bcUser = [self.firUser convertToBCUser];
    }
    return _bcUser;
}

-(NSMutableArray<BCChannel *> *)channels{
    if(!_channels){
        _channels = [NSMutableArray new];
    }
    return _channels;
}


#pragma mark - other setter & getter

-(FIRDatabaseReference *)usersSectionRef{
    if(!_usersSectionRef){
        _usersSectionRef = BCRef.root.section(BCRefUsersSection);
    }
    return _usersSectionRef;
}

-(FIRDatabaseReference *)channelsSectionRef{
    if(!_channelsSectionRef){
        _channelsSectionRef = BCRef.root.section(BCRefChannelsSection);
    }
    return _channelsSectionRef;
}

-(FIRDatabaseReference *)channelsRef{
    if(!_channelsRef){
        _channelsRef = BCRef.root.section(BCRefChannelsSection).user(self.bcUser);
    }
    return _channelsRef;
}

-(FIRDatabaseReference *)messagesSectionRef{
    if(!_messagesSectionRef){
        _messagesSectionRef = BCRef.root.section(BCRefMessagesSection);
    }
    return _messagesSectionRef;
}

-(FIRDatabaseReference *)messagesRef{
    if(!_messagesRef){
        _messagesRef = BCRef.root.section(BCRefMessagesSection).user(self.bcUser);
    }
    return _messagesRef;
}

-(FIRDatabaseReference *)friendsSectionRef{
    if(!_friendsSectionRef){
        _friendsSectionRef = BCRef.root.section(BCRefFriendsSection);
    }
    return _friendsSectionRef;
}

-(FIRDatabaseReference *)friendsRef{
    if(!_friendsRef){
        _friendsRef = BCRef.root.section(BCRefFriendsSection).user(self.bcUser);
    }
    return _friendsRef;
}

-(FIRDatabaseReference *)friendRequestsSectionRef{
    if(!_friendRequestsSectionRef){
        _friendRequestsSectionRef = BCRef.root.section(BCRefFriendRequestsSection);
    }
    return _friendRequestsSectionRef;
}

-(FIRDatabaseReference*)friendRequestsRef{
    if(!_friendRequestsRef){
        _friendRequestsRef = BCRef.root.section(BCRefFriendRequestsSection).user(self.bcUser);
    }
    return _friendRequestsRef;
}


#pragma mark - channels

-(RACSignal *)createChannelsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.channelsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *channels = [[BCChannel convertedToChannelsFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:channels];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)createChannel:(BCChannel *)channel forUser:(BCUser *)user{
    [BCRef.root.section(BCRefChannelsSection).user(user).child(channel.validKey) setValue:[channel json]];
}


#pragma mark - users

-(RACSignal *)createUsersSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.usersSectionRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *users = [[BCUser convertedToUserFromJSON:snapshot] mutableCopy];
            [subscriber sendNext:users];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)createUser:(BCUser *)user{
    [self.usersSectionRef.child(user.validKey) setValue:[user json]];
}

-(void)getUserWithIdentity:(NSString *)identity withCompletion:(void(^)(BCUser *user))completion{
    FIRDatabaseReference *ref = self.usersSectionRef.child(identity);
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if([snapshot.value isKindOfClass:[NSNull class]]){
            completion(nil);
        }else{
            BCUser *user = [BCUser convertedToUserFromJSON:snapshot];
            completion(user);
        }
    }];
}

#pragma mark - messages

-(RACSignal *)createMessagesSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.messagesRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *messagess = [[BCUser convertedToUsersFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:messagess];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)createMessage:(BCMessage *)message inChannel:(BCChannel *)channel withCompletion:(void(^)(BCMessage *, NSError *))completion{
    [[self.messagesRef.child(message.channelKey).section(BCRefMessagesSection) childByAutoId] setValue:[message json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            BCUser *other = [channel otherOf:self.bcUser];
            [[BCRef.root.section(BCRefMessagesSection).user(other).child(message.channelKey).section(BCRefMessagesSection) childByAutoId] setValue:[message json]];
            
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                BCMessage *returnMessage = [BCMessage convertedToMessageFromJSON:snapshot];
                [BCRef.root.section(BCRefChannelsSection).user(returnMessage.author).child(returnMessage.channelKey).child(@"lastMessage") setValue:[returnMessage json]];
                [BCRef.root.section(BCRefChannelsSection).user(returnMessage.author).child(returnMessage.channelKey).child(@"updatedDate") setValue:returnMessage.createdDate.description];
                
                [BCRef.root.section(BCRefChannelsSection).user(other).child(message.channelKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    if([snapshot.value isMemberOfClass:[NSNull class]]){
                        [self createChannel:channel forUser:other];
                    }else{
                        
                    }
                    [BCRef.root.section(BCRefChannelsSection).user(other).child(message.channelKey).child(@"lastMessage") setValue:[returnMessage json]];
                    
                    [BCRef.root.section(BCRefChannelsSection).user(other).child(returnMessage.channelKey).child(@"updatedDate") setValue:returnMessage.createdDate.description];
                }];
                completion(returnMessage,nil);
            }];
        }else{
            completion(nil,error);
        }
    }];
}

#pragma mark - friends

-(RACSignal *)createFriendsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *friends = [[BCUser convertedToUsersFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:friends];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)addFriend:(BCUser *)user{
    [self.friendsRef.child(user.validKey) setValue:[user json]];
}

#pragma mark - friendsRequest

-(RACSignal *)createFriendRequestsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *friendRequests = [[BCFriendRequest convertedToFriendRequestsFromJSONs:snapshot receiver:self.bcUser] mutableCopy];
            [subscriber sendNext:friendRequests];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)addFriendRequestFrom:(BCUser *)from to:(BCUser *)to{
    BCFriendRequest *friendRequest = [[BCFriendRequest alloc] initWithFrom:from to:to state:BCFriendRequestStateApplied];
    [self addFriendRequest:friendRequest];
}

-(void)addFriendRequest:(BCFriendRequest *)friendRequest{
    friendRequest.state = BCFriendRequestStateApplied;
    [self.friendRequestsRef.child(friendRequest.validKey) setValue:[friendRequest json]];
    [BCRef.root.section(BCRefFriendRequestsSection).user(friendRequest.to).child(friendRequest.validKey) setValue:[friendRequest json]];
}

-(void)acceptFriendRequest:(BCFriendRequest *)friendRequest{
    BCUser *other = [friendRequest otherOf:self.bcUser];
    [self.friendsRef.child(other.validKey) setValue:[other json]];
    [BCRef.root.section(BCRefFriendsSection).user(other).child(self.bcUser.validKey) setValue:[self.bcUser json]];
    [self.friendRequestsRef.child(friendRequest.validKey) setValue:nil];
    [BCRef.root.section(BCRefFriendRequestsSection).user(other).child(friendRequest.validKey) setValue:nil];
}

@end
