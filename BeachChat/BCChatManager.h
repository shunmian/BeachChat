//
//  BCChatManager.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCChannel.h"
#import "BCMessage.h"
#import "BCUser.h"
#import "BCFriendRequest.h"
#import "FIRUser+User.h"

typedef void(^observeCompletion)(NSArray *);

@interface BCChatManager : NSObject
@property (nonatomic, strong) FIRUser *firUser;
@property (nonatomic, strong,readonly) BCUser *bcUser;

//totoal app users, may not be your friends
@property (nonatomic, strong) NSMutableArray<BCUser *> *users;
//the app users that are your friends already
@property (nonatomic, strong) NSMutableArray<BCUser *> *friends;
@property (nonatomic, strong) NSMutableArray<BCFriendRequest*> *friendRequests;

@property (nonatomic, strong) NSMutableArray<BCChannel *> *channels;
@property (nonatomic, strong) NSMutableArray<BCMessage *> *messages;

@property (nonatomic, strong) FIRDatabaseReference *channelRef;
@property (nonatomic, strong) FIRDatabaseReference *userRef;
@property (nonatomic, strong) FIRDatabaseReference *messageRef;
@property (nonatomic, strong) FIRDatabaseReference *friendRef;
@property (nonatomic, strong) FIRDatabaseReference *friendRequestRef;
@property (nonatomic, strong) FIRDatabaseReference *timeRef;

+(instancetype)sharedManager;

#pragma mark - channels
-(void)observeChannelsWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;



-(void)createChannel:(BCChannel *)channel;

#pragma mark - users

-(void)observeUsersWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;

-(void)createUser:(BCUser *)user;

-(void)getUserWithIdentity:(NSString *)identity withCompletion:(void(^)(BCUser *user, NSError *error))completion;

#pragma mark - messages;
-(void)observeMessagesWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;

#pragma mark - friendRequests

-(void)addFriendRequest:(BCFriendRequest *)friendRequest;

-(void)acceptFriendRequest:(BCFriendRequest *)friendRequest;

-(void)deleteFriendRequestFrom:(BCUser *)from to:(BCUser *)to;



@end
