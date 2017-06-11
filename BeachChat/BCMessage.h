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

@class BCChannel;
@interface BCMessage : NSObject
@property(nonatomic, strong) BCUser *author;
@property(nonatomic, copy) NSString *channelKey;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, strong) NSDate *createdDate;

-(instancetype)initWithAuthor:(BCUser *)author
                      channelKey:(NSString *)channelKey
                         body:(NSString *)body
                  createdDate:(NSDate *)createdDate;

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                         body:(NSString *)body;

+(BCMessage *)convertedToMessageFromJSON:(FIRDataSnapshot *)snapshot;
+(NSArray <BCMessage *> *)convertedToMessagesFromJSONs:(FIRDataSnapshot *)snapshot;

-(NSDictionary *)json;
@end
