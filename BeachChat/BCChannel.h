//
//  BCChannel.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCUser.h"
#import "BCMessage.h"

@interface BCChannel : NSObject
@property (nonatomic, copy) NSString *identity;
@property (nonatomic, copy,readonly) NSString *validKey;
@property (nonatomic, copy) NSString *displayName;

@property (nonatomic, strong) BCUser *creator;
@property (nonatomic, strong) NSMutableArray <BCUser *> *otherUsers;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *updatedDate;
@property (nonatomic, strong) BCMessage *lastMessage;


-(instancetype)initWithCreator:(BCUser *)creator
                    otherUsers:(NSMutableArray <BCUser *>*)otherUsers
                   displayName:(NSString *)displayName
                   createdDate:(NSDate *)createdDate
                   updatedDate:(NSDate *)updatedDate
                   lastMessage:(BCMessage *)lastMessage;

-(instancetype)initFrom:(BCUser *)from to:(BCUser *)to;

-(NSDictionary *)json;
+(BCChannel *)convertedToChannelFromJSON:(FIRDataSnapshot *)snapshot;

-(BCUser *)otherOf:(BCUser *)user;

/* return channels sortedby updated date
 */
+(NSArray <BCChannel *> *)convertedToChannelsFromJSONs:(FIRDataSnapshot *)snapshot;
@end
