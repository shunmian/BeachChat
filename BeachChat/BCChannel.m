//
//  BCChannel.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChannel.h"


@interface BCChannel()
@property(nonatomic, copy, readwrite) NSString *validKey;
@end

@implementation BCChannel

static id ObjectOrNull(id object)
{
    return object ?: [NSNull null];
}

-(instancetype)initWithCreator:(BCUser *)creator
                    otherUsers:(NSMutableArray <BCUser *>*)otherUsers
                   displayName:(NSString *)displayName
              createdTimeStamp:(NSTimeInterval)createdTimeStamp
              updatedTimeStamp:(NSTimeInterval)updatedTimeStamp
                   lastMessage:(BCMessage *)lastMessage
                        isRead:(BOOL)isRead
           unreadMessageNumber:(NSInteger)unreadMessageNumber;
{
    if(self = [super init]){
        BCUser *to = (BCUser *)[otherUsers firstObject];
        NSComparisonResult compareResult = [creator.identity compare:to.identity];
        if(compareResult == NSOrderedAscending){
            _identity = [NSString stringWithFormat:@"%@&vs&%@",creator.validKey,to.validKey];
        }else{
            _identity = [NSString stringWithFormat:@"%@&vs&%@",to.validKey,creator.validKey];
        };
        _displayName = displayName? displayName:[NSString stringWithFormat:@"%@ %@",creator.displayName,to.displayName];
        _creator = creator;
        _otherUsers = otherUsers;
        _createdTimeStamp = createdTimeStamp;
        _updatedTimeStamp = updatedTimeStamp;
        _lastMessage = lastMessage;
        _validKey = [_identity stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        _unreadMessageNumber = unreadMessageNumber;
        _isRead = isRead;
    }
    return self;
}

-(instancetype)initFrom:(BCUser *)from to:(BCUser *)to{
    if(self = [self initWithCreator:from
                         otherUsers:[@[to] mutableCopy]
                        displayName:nil
                   createdTimeStamp:0
                   updatedTimeStamp:0
                        lastMessage:nil
                             isRead:NO
                unreadMessageNumber:0]){
    
    }
    return self;
}

-(NSDate *)createdDate{
    return [NSDate convertedToDateFromTimeInterval:_createdTimeStamp];
}

-(NSDate *)updatedDate{
    return [NSDate convertedToDateFromTimeInterval:_createdTimeStamp];
}

-(NSDictionary *)json{
    NSMutableDictionary *otherUsersJson = [NSMutableDictionary new];
    for(BCUser *user in self.otherUsers){
        [otherUsersJson setObject:[user json] forKey: user.validKey];
    };
    
    NSDictionary *dict = @{@"identity":ObjectOrNull(self.identity),
                           @"validkey":ObjectOrNull(self.validKey),
                           @"displayName":ObjectOrNull(self.displayName),
                           @"isRead":ObjectOrNull(@(self.isRead)),
                           @"unreadMessageNumber":ObjectOrNull(@(self.unreadMessageNumber)),
                           @"creator":ObjectOrNull([self.creator json]),
                           @"otherUsers":ObjectOrNull(otherUsersJson),
                           @"lastMessage":ObjectOrNull([self.lastMessage json]),
                           @"createdTimeStamp":[FIRServerValue timestamp],
                           @"updatedTimeStamp":[FIRServerValue timestamp]};
    return dict;
}

-(NSString *)description{
    NSMutableDictionary *otherUsersJson = [NSMutableDictionary new];
    for(BCUser *user in self.otherUsers){
        [otherUsersJson setObject:[user json] forKey: user.validKey];
    };
    NSDictionary *dict = @{@"identity":self.identity,
                           @"validkey":self.validKey,
                           @"displayName":self.displayName,
                           @"isRead":@(self.isRead),
                           @"unreadMessageNumber":@(self.unreadMessageNumber),
                           @"creator":[self.creator json],
                           @"otherUsers":otherUsersJson,
                           @"createdDate":[self createdDate],
                           @"updatedTimeStamp":[self updatedDate]};
    
    return [NSString stringWithFormat:@"%@",dict];
}

+(BCChannel *)convertedToChannelFromJSON:(FIRDataSnapshot *)snapshot{
    if(![snapshot isValueExist]) return nil;
    BCUser *creator = [BCUser convertedToUserFromJSON:[snapshot childSnapshotForPath:@"creator"]];
    NSDictionary *dataDict = snapshot.value;
    NSMutableArray *otherUsers = [NSMutableArray new];
    for(FIRDataSnapshot *userSnapshot in [snapshot childSnapshotForPath:@"otherUsers"].children){
        BCUser *user = [BCUser convertedToUserFromJSON:userSnapshot];
        [otherUsers addObject:user];
    }
    
    NSNumber *createdTimeStamp = (NSNumber *)dataDict[@"createdTimeStamp"];
    NSNumber *updatedTimeStamp = (NSNumber *)dataDict[@"updatedTimeStamp"];
    NSNumber *isRead = (NSNumber *)dataDict[@"isRead"];
    NSNumber *unreadMessageNumber = (NSNumber *)dataDict[@"unreadMessageNumber"];

    
    FIRDataSnapshot *lastMessageSnapshot = [snapshot childSnapshotForPath:@"lastMessage"];
    BCMessage *lastMessage = [BCMessage convertedToTextMessageFromJSON:lastMessageSnapshot];

    
    BCChannel *channel = [[BCChannel alloc] initWithCreator:creator
                                                 otherUsers:otherUsers
                                                displayName:dataDict[@"displayName"]
                                           createdTimeStamp:createdTimeStamp.doubleValue
                                           updatedTimeStamp:updatedTimeStamp.doubleValue
                                                lastMessage:lastMessage
                                                     isRead:isRead.boolValue
                                        unreadMessageNumber:unreadMessageNumber.integerValue];
    return channel;
}

+(NSArray <BCChannel *> *)convertedToChannelsFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *channels = [NSMutableArray new];
    for (FIRDataSnapshot *item in snapshot.children){
        BCChannel *channel = [BCChannel convertedToChannelFromJSON:item];
        [channels addObject:channel];
    }
    
    return [channels sortedArrayUsingComparator:^NSComparisonResult(BCChannel *obj1,BCChannel *obj2) {
        return [obj2.updatedDate compare:obj1.updatedDate];
    }];;
}

-(BCUser *)otherOf:(BCUser *)user{
    if([user.validKey isEqualToString:self.creator.validKey]){
        return self.otherUsers[0];
    }else{
        return self.creator;
    }
}

@end
