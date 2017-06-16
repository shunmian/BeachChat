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
@property(nonatomic, strong) NSString *mediaItemKey;

-(instancetype)initWithAuthor:(BCUser *)author
                      channelKey:(NSString *)channelKey
                         body:(NSString *)body
            createdTimeStamp:(NSTimeInterval)createdTimeStamp;

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                         body:(NSString *)body;


-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                mediatItemKey:(NSString *)mediaItemKey
             createdTimeStamp:(NSTimeInterval)createTimeStamp;

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                   mediatItem:(JSQMediaItem *)mediaItem;


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
@end
