//
//  BCMessage.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMessage.h"

@implementation BCMessage

-(instancetype)initWithAuthor:(BCUser *)author
                      channelKey:(NSString *)channelKey
                         body:(NSString *)body
             createdTimeStamp:(NSTimeInterval)createdTimeStamp{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _body = body;
        _createdTimeStamp = createdTimeStamp;
    }
    return self;
}

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                         body:(NSString *)body{
    
    if(self = [self initWithAuthor:author
                        channelKey:channelKey
                              body:body
                  createdTimeStamp:0]){
    
    }
    return self;
}

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                   mediatItem:(JSQMediaItem *)mediaItem{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _mediaItem = mediaItem;
    }
    return self;
}

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                mediatItemKey:(NSString *)mediaItemKey
             createdTimeStamp:(NSTimeInterval)createTimeStamp{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _mediaItemKey = mediaItemKey;
        _createdTimeStamp = createTimeStamp;
    }
    return self;
}

-(NSDate *)createdDate{
    return [self localDateFromTimeInterval:self.createdTimeStamp];
}

-(NSDate *)localDateFromTimeInterval:(NSTimeInterval)timeInterval{
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    return [BCDate convertToLoalTimeZone:sourceDate];
}

-(NSDictionary *)json{
    NSDictionary *dict = @{@"author":[self.author json],
                           @"channelKey":self.channelKey,
                           @"body":self.body,
                           @"createdDate":[FIRServerValue timestamp]};

    return dict;
}

-(NSDictionary *)photoJson{
    NSDictionary *dict = @{@"author":[self.author json],
                           @"channelKey":self.channelKey,
                           @"mediaItemKey":self.mediaItemKey,
                           @"createdDate":[FIRServerValue timestamp],
                           };
    return dict;
}

+(BCMessage *)convertedToTextMessageFromJSON:(FIRDataSnapshot *)snapshot{
    if([snapshot.value isKindOfClass:[NSNull class]]) return nil;
    
    NSDictionary *dataDict = snapshot.value;
    
    BCUser *author = [BCUser convertedToUserFromJSON:[snapshot childSnapshotForPath:@"author"]];
    NSString *body = dataDict[@"body"];
    
    NSNumber *timeInterval = dataDict[@"createdTimeStamp"];
    NSString *channelKey = dataDict[@"channelKey"];
    
    BCMessage *message = [[BCMessage alloc] initWithAuthor:author channelKey:channelKey body:body createdTimeStamp:timeInterval.integerValue];
    
    return message;
}

+(NSArray <BCMessage *> *)convertedToTextMessagesFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *messages = [NSMutableArray new];
    for (FIRDataSnapshot *item in snapshot.children){
        BCMessage *message = [BCMessage convertedToTextMessageFromJSON:item];
        [messages addObject:message];
    }
    
    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(BCMessage *obj1, BCMessage * obj2) {
        return [obj1.createdDate compare:obj2.createdDate];
    }];
    
    return sortedMessages;
}

+(BCMessage *)convertedToPhotoMessageFromJSON:(FIRDataSnapshot *)snapshot{
    if([snapshot.value isKindOfClass:[NSNull class]]) return nil;
    BCUser *author = [BCUser convertedToUserFromJSON:[snapshot childSnapshotForPath:@"author"]];
    NSDictionary *dataDict = snapshot.value;
    NSString *channelKey = dataDict[@"channelKey"];
    NSString *mediaItemKey = dataDict[@"mediaItemKey"];
    NSNumber *createdTimeStamp = dataDict[@"createdTimeStamp"];
    BCMessage *photoMessage = [[BCMessage alloc] initWithAuthor:author
                                                     channelKey:channelKey
                                                  mediatItemKey:mediaItemKey
                                               createdTimeStamp:createdTimeStamp.integerValue];
    return photoMessage;
}

+(NSArray <BCMessage *> *)convertedToTextAndPhotoMessagesFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *messages = [NSMutableArray new];
    for (FIRDataSnapshot *item in snapshot.children){
        BCMessage *message;
        if([[item childSnapshotForPath:@"mediaItemKey"].value isKindOfClass:[NSNull class]]){
            message = [BCMessage convertedToTextMessageFromJSON:item];
        }else{
            message = [BCMessage convertedToPhotoMessageFromJSON:item];
        }
        [messages addObject:message];
    }
    
    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(BCMessage *obj1, BCMessage * obj2) {
        return [obj1.createdDate compare:obj2.createdDate];
    }];
    
    return sortedMessages;

}

@end
