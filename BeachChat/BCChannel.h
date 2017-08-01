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
@property (nonatomic, strong, readonly) NSDate *createdDate;
@property (nonatomic, assign) NSTimeInterval createdTimeStamp;
@property (nonatomic, assign) NSTimeInterval updatedTimeStamp;
@property (nonatomic, strong, readonly) NSDate *updatedDate;
@property (nonatomic, strong) BCMessage *lastMessage;
@property (nonatomic, assign) NSInteger unreadMessageNumber;
@property (nonatomic, assign) BOOL isRead;


-(instancetype)initWithCreator:(BCUser *)creator
                    otherUsers:(NSMutableArray <BCUser *>*)otherUsers
                   displayName:(NSString *)displayName
              createdTimeStamp:(NSTimeInterval)createdTimeStamp
              updatedTimeStamp:(NSTimeInterval)updatedTimeStamp
                   lastMessage:(BCMessage *)lastMessage
                        isRead:(BOOL)isRead
           unreadMessageNumber:(NSInteger)unreadMessageNumber;

-(instancetype)initWithCreator:(BCUser *)creator
                    otherUsers:(NSMutableArray <BCUser *>*)otherUsers
                   displayName:(NSString *)displayName
              createdTimeStamp:(NSTimeInterval)createdTimeStamp
              updatedTimeStamp:(NSTimeInterval)updatedTimeStamp
                   lastMessage:(BCMessage *)lastMessage;

-(instancetype)initFrom:(BCUser *)from to:(BCUser *)to;

-(NSDictionary *)json;
+(BCChannel *)convertedToChannelFromJSON:(FIRDataSnapshot *)snapshot;
-(BCUser *)otherOf:(BCUser *)user;

/* return channels sortedby updated date
 */
+(NSArray <BCChannel *> *)convertedToChannelsFromJSONs:(FIRDataSnapshot *)snapshot;
@end
