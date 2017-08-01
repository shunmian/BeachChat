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
@property (nonatomic, assign) BOOL isSignIn;

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

static NSString *const kPhotoNotSetKey = @"NOTSET";

#pragma mark - Life Cycle


-(void)setUpWithEntryData:(id)data isSignIn:(BOOL)isSignIn{
    NSAssert([data isKindOfClass:[FIRUser class]], @"data must be FIRUser class");
    self.firUser = (FIRUser *)data;
    self.isSignIn = isSignIn;
    if(!isSignIn){
        [self createUser:[self.firUser convertToBCUser]];
    }
    
    [self setUpSignals];
}

-(void)setUpSignals{
    
    RAC(self, bcUser) = [self createUserSignalForvalidKey:[self.firUser convertToBCUser].validKey];
//    RAC(self,channels) = [self createChannelsSignal];
//    RAC(self,users) = [self createUsersSignal];
//    RAC(self,friends) = [self createFriendsSignal];
//    RAC(self,friendRequests) = [self createFriendRequestsSignal];
    
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

-(void)createChannel:(BCChannel *)channel forUser:(BCUser *)user WithCompletion:(void(^)(BCChannel *))completion{
    [self getUpdatedChannel:channel forUser:user withCompletion:^(BCChannel *updatedChannel) {
        [BCRef.root.section(BCRefChannelsSection).user(user).child(channel.validKey) setValue:[updatedChannel json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if(!error){
                completion(updatedChannel);
            }else{
                completion(nil);
            }
        }];
    }];
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

-(RACSignal *)createUserSignalForvalidKey:(NSString *)validKey{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.usersSectionRef.child(validKey) observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(![snapshot isValueExist]){
                [subscriber sendNext:nil];
            }else{
                BCUser *user = [BCUser convertedToUserFromJSON:snapshot];
                [subscriber sendNext:user];
            }
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

-(void)getUpdatedUser:(BCUser *)user withCompletion:(void(^)(BCUser *))completion{
    FIRDatabaseReference *userRef = BCRef.root.section(BCRefUsersSection).user(user);
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BCUser *updatedUser = [BCUser convertedToUserFromJSON:snapshot];
        if(!updatedUser){
            completion(user);
        }
        completion(updatedUser);
    }];
}

-(void)getUpdatedMessage:(BCMessage *)message withCompletion:(void(^)(BCMessage *))completion{
    FIRDatabaseReference *messageRef = BCRef.root.section(BCRefMessagesSection).user(message.author).child(message.channelKey).child(message.validKey);
    
    [messageRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BCMessage *updatedMessage;
        if([BCMessage isMediaItem:snapshot]){
            updatedMessage = [BCMessage convertedToPhotoMessageFromJSON:snapshot];
        }else{
            updatedMessage = [BCMessage convertedToTextMessageFromJSON:snapshot];
        }

        [self getUpdatedUser:message.author withCompletion:^(BCUser *updatedUser) {
            if(!updatedMessage){
                message.author = updatedUser;
                completion(message);
            }else{
                updatedMessage.author = updatedUser;
                completion(updatedMessage);
            }
        }];
    }];
}

-(void)getUpdatedChannel:(BCChannel *)channel forUser:(BCUser *)user withCompletion:(void(^)(BCChannel *))completion{
    FIRDatabaseReference *ref = BCRef.root.section(BCRefChannelsSection).user(user).child(channel.validKey);
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BCChannel *updatedChannel = [BCChannel convertedToChannelFromJSON:snapshot];
        [self getUpdatedUser:channel.creator withCompletion:^(BCUser *updatedcreator) {
            [self getUpdatedUser:channel.otherUsers[0] withCompletion:^(BCUser *updatedOther) {
                if(!updatedChannel){
                    channel.creator = updatedcreator;
                    channel.otherUsers = [@[updatedOther] mutableCopy];
                    completion(channel);
                }else{
                    updatedChannel.creator = updatedcreator;
                    updatedChannel.otherUsers = [@[updatedOther] mutableCopy];
                    completion(updatedChannel);
                }
            }];
        }];
    }];
}

-(void)createTextMessage:(BCMessage *)message inChannel:(BCChannel *)channel withCompletion:(void(^)(BCMessage *, NSError *))completion{
    
    [self getUpdatedMessage:message withCompletion:^(BCMessage *updatedMessage) {
        [self getUpdatedChannel:channel forUser:self.bcUser withCompletion:^(BCChannel *updatedChannel) {
            [self.messagesRef.child(updatedMessage.channelKey).section(BCRefMessagesSection).child(updatedMessage.validKey) setValue:[updatedMessage json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref){
                if(!error){
                    BCUser *other = [updatedChannel otherOf:self.bcUser];
                    [BCRef.root.section(BCRefMessagesSection).user(other).child(updatedMessage.channelKey).section(BCRefMessagesSection).child(updatedMessage.validKey) setValue:[updatedMessage json]];
                    updatedChannel.lastMessage = updatedMessage;
                    updatedChannel.updatedTimeStamp= updatedMessage.createdTimeStamp;
                    updatedChannel.isRead = YES;
                    updatedChannel.unreadMessageNumber = 0;
                    [BCRef.root.section(BCRefChannelsSection).user(updatedMessage.author).child(updatedMessage.channelKey) setValue:[updatedChannel json]];
                    
                    [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        if([snapshot.value isMemberOfClass:[NSNull class]]){
                            [self createChannel:updatedChannel forUser:other WithCompletion:^(BCChannel *returnedChannel) {
                            }];
                        }else{
                            
                        };
                        [self getUpdatedChannel:channel forUser:other withCompletion:^(BCChannel *otherUpdatedChannel) {
                            if(!otherUpdatedChannel.isRead){
                                otherUpdatedChannel.unreadMessageNumber += 1;
                            }
                            otherUpdatedChannel.lastMessage = updatedMessage;
                            otherUpdatedChannel.updatedTimeStamp = updatedMessage.createdTimeStamp;
                            [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) setValue:[otherUpdatedChannel json]];
                        }];

                    }];
                }
            }];
        }];
    }];
}

-(void)createPhotoMessage:(BCMessage *)photoMessage
                withAsset:(PHAsset *)photoAsset
                inChannel:(BCChannel *)channel
           withCompletion:(void(^)(BCMessage *, NSError *))completion{
    
    FIRDatabaseReference *photoMessageFromRef = BCRef.root.section(BCRefMessagesSection).user(self.bcUser).child(channel.validKey).section(BCRefMessagesSection).child(photoMessage.validKey);
    
    BCUser *other = [channel otherOf:self.bcUser];
    FIRDatabaseReference *photoMessageToRef = BCRef.root.section(BCRefMessagesSection).user(other).child(channel.validKey).section(BCRefMessagesSection).child(photoMessage.validKey);
    
    [self getUpdatedMessage:photoMessage withCompletion:^(BCMessage *updatedMessage) {
        [self getUpdatedChannel:channel forUser:self.bcUser withCompletion:^(BCChannel *updatedChannel) {
            [photoMessageFromRef setValue:[updatedMessage photoJson] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if(!error){
                    [photoMessageToRef setValue:[updatedMessage photoJson]];
                    updatedChannel.lastMessage = updatedMessage;
                    updatedChannel.updatedTimeStamp= updatedMessage.createdTimeStamp;
                    updatedChannel.isRead = YES;
                    updatedChannel.unreadMessageNumber = 0;
                    [BCRef.root.section(BCRefChannelsSection).user(updatedMessage.author).child(updatedMessage.channelKey) setValue:[updatedChannel json]];
                    
                    [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        if([snapshot.value isMemberOfClass:[NSNull class]]){
                            [self createChannel:updatedChannel forUser:other WithCompletion:^(BCChannel *returnedChannel) {
                            }];
                        }else{
                            
                        };
                        [self getUpdatedChannel:channel forUser:other withCompletion:^(BCChannel *otherUpdatedChannel) {
                            if(!otherUpdatedChannel.isRead){
                                otherUpdatedChannel.unreadMessageNumber += 1;
                            }
                            otherUpdatedChannel.lastMessage = updatedMessage;
                            otherUpdatedChannel.updatedTimeStamp = updatedMessage.createdTimeStamp;
                            [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) setValue:[otherUpdatedChannel json]];
                        }];
                    }];
                    [photoAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                        NSURL *imageFileURL = contentEditingInput.fullSizeImageURL;
                        NSString *timeIntervalKey = updatedMessage.validKey;
                        
                        FIRStorageReference *destRef = BCRef.storage.section(BCRefChannelsSection).child(updatedChannel.validKey).child(updatedMessage.validKey);
                        
                        [destRef putFile:imageFileURL metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                            if(!error){
                                [photoMessageFromRef.child(@"mediaItemURL") setValue:[BCRef.storage child:metadata.path].description];
                                [photoMessageToRef.child(@"mediaItemURL") setValue:[BCRef.storage child:metadata.path].description];
                                [BCRef.root.section(BCRefMessagesSection).user(self.bcUser).child(updatedMessage.validKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                    BCMessage *returnedMessage = [BCMessage convertedToPhotoMessageFromJSON:snapshot];
                                    completion(returnedMessage,nil);
                                    
                                }];
                            }else{
                                NSLog(@"Error uploading photo: %@",error.localizedDescription);
                                completion(nil,error);
                            }
                        }];
                    }];
                }
            }];
        }];
        
    }];
}

-(void)createFileMessage:(BCMessage *)fileMessage
                withData:(NSData *)data
                inChannel:(BCChannel *)channel
           withCompletion:(void(^)(BCMessage *, NSError *))completion{
    
    FIRDatabaseReference *fileMessageFromRef = BCRef.root.section(BCRefMessagesSection).user(self.bcUser).child(channel.validKey).section(BCRefMessagesSection).child(fileMessage.validKey);
    
    BCUser *other = [channel otherOf:self.bcUser];
    FIRDatabaseReference *fileMessageToRef = BCRef.root.section(BCRefMessagesSection).user(other).child(channel.validKey).section(BCRefMessagesSection).child(fileMessage.validKey);
    
    [self getUpdatedMessage:fileMessage withCompletion:^(BCMessage *updatedMessage) {
        [self getUpdatedChannel:channel forUser:self.bcUser withCompletion:^(BCChannel *updatedChannel) {
            [fileMessageFromRef setValue:[updatedMessage photoJson] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if(!error){
                    [fileMessageToRef setValue:[updatedMessage photoJson]];
                    updatedChannel.lastMessage = updatedMessage;
                    updatedChannel.updatedTimeStamp= updatedMessage.createdTimeStamp;
                    updatedChannel.isRead = YES;
                    updatedChannel.unreadMessageNumber = 0;
                    [BCRef.root.section(BCRefChannelsSection).user(updatedMessage.author).child(updatedMessage.channelKey) setValue:[updatedChannel json]];
                    
                    [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        if([snapshot.value isMemberOfClass:[NSNull class]]){
                            [self createChannel:updatedChannel forUser:other WithCompletion:^(BCChannel *returnedChannel) {
                            }];
                        }else{
                            
                        };
                        [self getUpdatedChannel:channel forUser:other withCompletion:^(BCChannel *otherUpdatedChannel) {
                            if(!otherUpdatedChannel.isRead){
                                otherUpdatedChannel.unreadMessageNumber += 1;
                            }
                            otherUpdatedChannel.lastMessage = updatedMessage;
                            otherUpdatedChannel.updatedTimeStamp = updatedMessage.createdTimeStamp;
                            [BCRef.root.section(BCRefChannelsSection).user(other).child(updatedMessage.channelKey) setValue:[otherUpdatedChannel json]];
                        }];
                    }];
                    
                    FIRStorageReference *ref = BCRef.storage.section(BCRefChannelsSection).child(channel.validKey).child(fileMessage.validKey);
                    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
                    metadata.contentType = @"imag/jpeg";
                    
                    [ref putData:data metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                        if(!error){
                            [fileMessageFromRef.child(@"mediaItemURL") setValue:[BCRef.storage child:metadata.path].description];
                            [fileMessageToRef.child(@"mediaItemURL") setValue:[BCRef.storage child:metadata.path].description];
                            [BCRef.root.section(BCRefMessagesSection).user(self.bcUser).child(updatedMessage.validKey) observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                BCMessage *returnedMessage = [BCMessage convertedToPhotoMessageFromJSON:snapshot];
                                completion(returnedMessage,nil);
                                
                            }];
                        }else{
                            completion(nil,error);
                        }
                    }];
                }
            }];
        }];
    }];
}

-(void)fetchImageDataAtURL:(NSString *)url
              forMediaItem:(JSQPhotoMediaItem *)mediaItem
clearsPhotoMessgeMapOnSuccessForKey:(NSString *)key
             withComletion:(void(^)(JSQPhotoMediaItem *returnMediaItem, NSError * error))completion{
    FIRStorageReference *ref = [[FIRStorage storage] referenceForURL:url];
    [ref dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error downloading image data: %@",error.description);
            completion(nil,error);
        }
        
        [ref metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error){
                NSLog(@"Error downloading metadata: %@",error.description);
                completion(nil,error);
            }
            
            if([metadata.contentType isEqualToString: @"image/gif"]){
                mediaItem.image = [UIImage imageWithData:data];
            }else{
                mediaItem.image = [UIImage imageWithData:data];
            }
            completion(mediaItem,nil);
        }];
        
    }];
}



#pragma mark - create avatarMessage
-(void)createAvatar:(BCAvatar *)avatar
          withAsset:(PHAsset *)photoAsset
     withCompletion:(void(^)(BCAvatar *, NSError *))completion{
    
    FIRDatabaseReference *avatarRef = BCRef.root.section(BCRefUsersSection).user(self.bcUser).child(avatar.validKey);
    
    [avatarRef setValue:[avatar json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                BCAvatar *returnAvatar = [BCAvatar convertedToAvatarFromJSON:snapshot];
                
                [photoAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                    NSURL *imageFileURL = contentEditingInput.fullSizeImageURL;
//                    NSString *timeIntervalKey = photoMessage.validKey;
                    
                    FIRStorageReference *destRef = BCRef.storage.section(BCRefUsersSection).user(avatar.user).child(returnAvatar.validKey);
                    
                    [destRef putFile:imageFileURL metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                        if(!error){
                            [avatarRef.child(@"url") setValue:[BCRef.storage child:metadata.path].description];
                        }else{
                            NSLog(@"Error uploading photo: %@",error.localizedDescription);
                        }
                    }];
                }];
                completion(returnAvatar,nil);
            }];
        }else{
            completion(nil,error);
        }
    }];
}

-(void)createAvatar:(BCAvatar *)avatar
           withData:(NSData *)data
     withCompletion:(void(^)(BCAvatar *, NSError *))completion{
    
    FIRDatabaseReference *avatarRef = BCRef.root.section(BCRefUsersSection).user(avatar.user).child(avatar.validKey);
    
    [avatarRef setValue:[avatar json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                BCAvatar *returnAvatar = [BCAvatar convertedToAvatarFromJSON:snapshot];
                
                FIRStorageReference *ref = BCRef.storage.section(BCRefUsersSection).user(returnAvatar.user).child(returnAvatar.validKey);
                
                FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
                metadata.contentType = @"imag/jpeg";
                
                [ref putData:data metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                    if(!error){
                        [avatarRef.child(@"url") setValue:[BCRef.storage child:metadata.path].description];
                    }
                }];
                completion(returnAvatar,nil);
            }];
        }else{
            completion(nil,error);
        }
    }];
}

-(void)fetchImageDataAtURL:(NSString *)url
             withComletion:(void(^)(UIImage *image, NSError * error))completion{
    FIRStorageReference *ref = [[FIRStorage storage] referenceForURL:url];
    [ref dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error downloading image data: %@",error.description);
            completion(nil,error);
        }
        
        [ref metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error){
                NSLog(@"Error downloading metadata: %@",error.description);
                completion(nil,error);
            }
            UIImage *image = [UIImage imageWithData:data];
            completion(image,nil);
        }];
        
    }];
}


//putdata to be continue


-(void)deleteMessage:(BCMessage *)message
           inMessges:(NSMutableArray<BCMessage *>*)messages
           inChannel:(BCChannel *)channel
      withCompletion:(void(^)(BCMessage *, NSError *))completion{
    [messages removeObject:message];
    [self.messagesRef.child(channel.validKey).section(BCRefMessagesSection).child(message.validKey) setValue:nil withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(!error){
            NSTimeInterval updatedTimeStamp = [messages lastObject].createdTimeStamp;
            [self.channelsRef.child(channel.validKey).child(@"lastMessage") setValue:[[messages lastObject] json]];
            [self.channelsRef.child(channel.validKey).child(@"updatedTimeStamp") setValue:@(updatedTimeStamp)];
            completion(message,nil);
        }else{
            NSLog(@"message remove fail in service: %@",message);
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
