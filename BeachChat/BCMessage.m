//
//  BCMessage.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMessage.h"

@interface BCMessage()
@property(nonatomic, strong, readwrite) NSString *validKey;
@end

@implementation BCMessage


-(instancetype)initFromServerWithAuthor:(BCUser *)author
                             channelKey:(NSString *)channelKey
                                   body:(NSString *)body
                               validKey:(NSString *)validKey
                       createdTimeStamp:(NSTimeInterval)createdTimeStamp{
    
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _validKey = validKey;
        _body = body;
        _createdTimeStamp = createdTimeStamp;
    }
    return self;
}

-(instancetype)initFromLocalWithAuthor:(BCUser *)author
                            channelKey:(NSString *)channelKey
                                  body:(NSString *)body{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
        _validKey = [NSString stringWithFormat:@"%lld",(int64_t)(t*1000)];
        _body = body;
        _createdTimeStamp = 0;
    }
    return self;
}

-(instancetype)initFromServerWithAuthor:(BCUser *)author
                             channelKey:(NSString *)channelKey
                                   body:(NSString *)body
                               validKey:(NSString *)validKey
                          mediatItemKey:(NSString *)mediaItemURL
                        createdTimStamp:(NSTimeInterval)createdTimeStamp{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _body = body;
        _validKey = validKey;
        _mediaItemURL = mediaItemURL;
        _createdTimeStamp = createdTimeStamp;
    }
    return self;
}

//-(instancetype)initFromLocalWithAuthor:(BCUser *)author
//                            channelKey:(NSString *)channelKey
//                            mediatItem:(JSQPhotoMediaItem *)mediaItem{
//    if(self = [super init]){
//        _author = author;
//        _channelKey = channelKey;
//        _mediaItem = mediaItem;
//        NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
//        _validKey = [NSString stringWithFormat:@"%@&+&%f",_channelKey,t*1000];
//        _createdTimeStamp = 0;
//    }
//    return self;
//}

-(instancetype)initFromLocalWithAuthor:(BCUser *)author
                            channelKey:(NSString *)channelKey
                         mediatItemURL:(NSString *)mediaItemURL{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _body = @"[image]";
        _mediaItemURL = mediaItemURL;
        NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
        _validKey = [NSString stringWithFormat:@"%lld",(int64_t)(t*1000)];
        _createdTimeStamp = 0;
    }
    return self;
}




-(NSDate *)createdDate{
    return [NSDate convertedToDateFromTimeInterval:self.createdTimeStamp];
}



-(NSDictionary *)json{
    NSDictionary *dict = @{@"author":[self.author json],
                           @"channelKey":self.channelKey,
                           @"body":self.body,
                           @"validKey":self.validKey,
                           @"createdTimeStamp":[FIRServerValue timestamp]};

    return dict;
}

-(NSDictionary *)photoJson{
    NSDictionary *dict = @{@"author":[self.author json],
                           @"channelKey":self.channelKey,
                           @"mediaItemURL":self.mediaItemURL,
                           @"body":self.body,
                           @"validKey":self.validKey,
                           @"createdTimeStamp":[FIRServerValue timestamp],
                           };
    return dict;
}

+(BCMessage *)convertedToTextMessageFromJSON:(FIRDataSnapshot *)snapshot{
    if([snapshot.value isKindOfClass:[NSNull class]]) return nil;
    
    NSDictionary *dataDict = snapshot.value;
    
    BCUser *author = [BCUser convertedToUserFromJSON:[snapshot childSnapshotForPath:@"author"]];
    NSString *body = dataDict[@"body"];
    
    NSNumber *timeInterval = dataDict[@"createdTimeStamp"];
    NSString *validKey = dataDict[@"validKey"];
    NSString *channelKey = dataDict[@"channelKey"];
    
    BCMessage *message = [[BCMessage alloc] initFromServerWithAuthor:author channelKey:channelKey body:body validKey:validKey createdTimeStamp:timeInterval.doubleValue];
    
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
    NSString *mediaItemURL = dataDict[@"mediaItemURL"];
    NSString *validKey = dataDict[@"validKey"];
    NSString *body = dataDict[@"body"];
    NSNumber *createdTimeStamp = dataDict[@"createdTimeStamp"];
    BCMessage *photoMessage = [[BCMessage alloc] initFromServerWithAuthor:author channelKey:channelKey body:body validKey:validKey mediatItemKey:mediaItemURL createdTimStamp:createdTimeStamp.doubleValue];
    return photoMessage;
}

+(NSArray <BCMessage *> *)convertedToTextAndPhotoMessagesFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *messages = [NSMutableArray new];
    for (FIRDataSnapshot *item in snapshot.children){
        BCMessage *message;
        if([[item childSnapshotForPath:@"mediaItemURL"].value isKindOfClass:[NSNull class]]){
            message = [BCMessage convertedToTextMessageFromJSON:item];
        }else{
            message = [BCMessage convertedToPhotoMessageFromJSON:item];
        }
        [messages addObject:message];
    }
    
    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(BCMessage *obj1, BCMessage * obj2) {
        return [obj1 compare:obj2];
    }];
    
    return sortedMessages;
}

- (NSComparisonResult)compare:(id)object{
    NSCParameterAssert([object isKindOfClass:[BCMessage class]]);
    BCMessage *other = (BCMessage *)object;
    if(self.createdTimeStamp < other.createdTimeStamp){
        return NSOrderedAscending;
    }else if(self.createdTimeStamp > other.createdTimeStamp){
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}

-(BOOL)isMediaItem{
    if(self.mediaItemURL){
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isMediaItem:(FIRDataSnapshot *)snapshot{
    if([[snapshot childSnapshotForPath:@"mediaItemURL"].value isKindOfClass:[NSNull class]]){
        return NO;
    }else{
        return YES;
    }
}

@end
