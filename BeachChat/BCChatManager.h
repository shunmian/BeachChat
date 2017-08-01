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
#import <Photos/Photos.h>

@class BCAvatar;
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


#pragma mark - Ref
@property (nonatomic, strong, readonly) FIRDatabaseReference *usersSectionRef;

@property (nonatomic, strong, readonly) FIRDatabaseReference *channelsSectionRef;
@property (nonatomic, strong, readonly) FIRDatabaseReference *channelsRef;

@property (nonatomic, strong, readonly) FIRDatabaseReference *messagesSectionRef;
@property (nonatomic, strong, readonly) FIRDatabaseReference *messagesRef;

@property (nonatomic, strong, readonly) FIRDatabaseReference *friendsSectionRef;
@property (nonatomic, strong, readonly) FIRDatabaseReference *friendsRef;

@property (nonatomic, strong, readonly) FIRDatabaseReference *friendRequestsSectionRef;
@property (nonatomic, strong, readonly) FIRDatabaseReference *friendRequestsRef;



+(instancetype)sharedManager;
-(void)setUpWithEntryData:(id)data isSignIn:(BOOL)isSignIn;
#pragma mark - channels
-(void)observeChannelsWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;

-(void)createChannel:(BCChannel *)channel forUser:(BCUser *)user WithCompletion:(void(^)(BCChannel *))completion;

#pragma mark - users

-(void)observeUsersWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;

-(void)createUser:(BCUser *)user;

-(void)getUserWithIdentity:(NSString *)identity withCompletion:(void(^)(BCUser *user))completion;

#pragma mark - messages
-(void)observeMessagesWithEventType:(FIRDataEventType )eventType completion:(observeCompletion)completion;

-(void)createTextMessage:(BCMessage *)message
           inChannel:(BCChannel *)channel
      withCompletion:(void(^)(BCMessage *, NSError *))completion;

-(void)createPhotoMessage:(BCMessage *)photoMessage
                withAsset:(PHAsset *)photoAsset
                inChannel:(BCChannel *)channel
           withCompletion:(void(^)(BCMessage *, NSError *))completion;

-(void)createFileMessage:(BCMessage *)fileMessage
                withData:(NSData *)data
               inChannel:(BCChannel *)channel
          withCompletion:(void(^)(BCMessage *, NSError *))completion;

-(void)fetchImageDataAtURL:(NSString *)url
              forMediaItem:(JSQPhotoMediaItem *)mediaItem
clearsPhotoMessgeMapOnSuccessForKey:(NSString *)key
             withComletion:(void(^)(JSQPhotoMediaItem *returnMediaItem, NSError * error))completion;

-(void)deleteMessage:(BCMessage *)message
           inMessges:(NSMutableArray<BCMessage *>*)messages
           inChannel:(BCChannel *)channel
      withCompletion:(void(^)(BCMessage *, NSError *))completion;

#pragma mark - avatar

-(void)createAvatar:(BCAvatar *)avatar
          withAsset:(PHAsset *)photoAsset
     withCompletion:(void(^)(BCAvatar *, NSError *))completion;

-(void)createAvatar:(BCAvatar *)avatar
           withData:(NSData *)data
     withCompletion:(void(^)(BCAvatar *, NSError *))completion;

-(void)fetchImageDataAtURL:(NSString *)url
             withComletion:(void(^)(UIImage *image, NSError * error))completion;


#pragma mark - friendRequests

-(void)addFriendRequest:(BCFriendRequest *)friendRequest;

-(void)acceptFriendRequest:(BCFriendRequest *)friendRequest;

-(void)deleteFriendRequestFrom:(BCUser *)from to:(BCUser *)to;



@end
