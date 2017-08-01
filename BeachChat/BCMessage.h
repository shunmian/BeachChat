//
//  BCMessage.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCUser.h"
#import "BCChannel.h"
#import <JSQPhotoMediaItem.h>

@class BCChannel;
@interface BCMessage : NSObject
@property(nonatomic, strong) BCUser *author;
@property(nonatomic, copy) NSString *channelKey;
@property(nonatomic, copy) NSString *body;

@property(nonatomic, strong, readonly) NSDate *createdDate;
@property(nonatomic, assign) NSTimeInterval createdTimeStamp;

@property(nonatomic, strong) JSQPhotoMediaItem *mediaItem;
@property(nonatomic, strong) NSString *mediaItemURL;

//valid key is the createdTimeInterval locally, which is used to keep track of message's key in FRIBASE when to remove the message.
@property(nonatomic, strong, readonly) NSString *validKey;




-(instancetype)initFromLocalWithAuthor:(BCUser *)author
                            channelKey:(NSString *)channelKey
                                  body:(NSString *)body;


-(instancetype)initFromLocalWithAuthor:(BCUser *)author
                            channelKey:(NSString *)channelKey
                         mediatItemURL:(NSString *)mediaItemURL;


//Text Messages
+(BCMessage *)convertedToTextMessageFromJSON:(FIRDataSnapshot *)snapshot;
+(NSArray <BCMessage *> *)convertedToTextMessagesFromJSONs:(FIRDataSnapshot *)snapshot;

//Photo Messages
+(BCMessage *)convertedToPhotoMessageFromJSON:(FIRDataSnapshot *)snapshot;
+(NSArray <BCMessage *> *)convertedToPhotoMessagesFromJSONs:(FIRDataSnapshot *)snapshot;

//Both Text and Photo Messages
+(NSArray <BCMessage *> *)convertedToTextAndPhotoMessagesFromJSONs:(FIRDataSnapshot *)snapshot;

-(NSDictionary *)json;
-(NSDictionary *)photoJson;
-(BOOL)isMediaItem;
+(BOOL)isMediaItem:(FIRDataSnapshot *)snapshot;
@end
