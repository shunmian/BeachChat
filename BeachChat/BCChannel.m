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

-(instancetype)initWithCreator:(BCUser *)creator
                    otherUsers:(NSMutableArray<BCUser *> *)otherUsers
                   displayName:(NSString *)displayName
                   createdDate:(NSDate *)createdDate
                   updatedDate:(NSDate *)updatedDate
                   lastMessage:(BCMessage *)lastMessage
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
        _createdDate = createdDate;
        _updatedDate = updatedDate;
        _lastMessage = lastMessage;
        _validKey = [_identity stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    }
    return self;
}

-(instancetype)initFrom:(BCUser *)from to:(BCUser *)to{
    NSDate *date = [NSDate date];
    if(self = [self initWithCreator:from
                         otherUsers:[@[to] mutableCopy]
                        displayName:nil
                        createdDate:date
                        updatedDate:date
                        lastMessage:nil]){
    
    }
    return self;
}

-(NSDictionary *)json{
    NSMutableDictionary *otherUsersJson = [NSMutableDictionary new];
    for(BCUser *user in self.otherUsers){
        [otherUsersJson setObject:[user json] forKey: user.validKey];
    };
    
    NSDictionary *dict = @{@"identity":self.identity,
                           @"validkey":self.validKey,
                           @"displayName":self.displayName,
                           @"creator":[self.creator json],
                           @"otherUsers":otherUsersJson,
                           @"createdDate":[FIRServerValue timestamp],
                           @"updatedDate":[FIRServerValue timestamp]};
    return dict;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@",[self json]];
}

+(BCChannel *)convertedToChannelFromJSON:(FIRDataSnapshot *)snapshot{
    BCUser *creator = [BCUser convertedFromJSON:[snapshot childSnapshotForPath:@"creator"]];
    NSDictionary *dataDict = snapshot.value;
    NSMutableArray *otherUsers = [NSMutableArray new];
    for(FIRDataSnapshot *userSnapshot in [snapshot childSnapshotForPath:@"otherUsers"].children){
        BCUser *user = [BCUser convertedFromJSON:userSnapshot];
        [otherUsers addObject:user];
    }
    
    NSNumber *timeInterval = dataDict[@"createdDate"];
    NSTimeInterval t = timeInterval.integerValue;
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSince1970:t/1000];
    NSDate *createdDate = [BCDate convertToLoalTimeZone:sourceDate];
    
    
    timeInterval = dataDict[@"updatedDate"];
    t = timeInterval.integerValue;
    sourceDate = [NSDate dateWithTimeIntervalSince1970:t/1000];
    NSDate *updatedDate = [BCDate convertToLoalTimeZone:sourceDate];
    
    FIRDataSnapshot *lastMessageSnapshot = [snapshot childSnapshotForPath:@"lastMessage"];
    BCMessage *lastMessage = [BCMessage convertedToMessageFromJSON:lastMessageSnapshot];

    
    
    BCChannel *channel = [[BCChannel alloc] initWithCreator:creator
                                                 otherUsers:otherUsers
                                                displayName:dataDict[@"displayName"]
                                                createdDate:createdDate
                                                updatedDate:updatedDate
                                                lastMessage:lastMessage];
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
