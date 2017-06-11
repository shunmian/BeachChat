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
                  createdDate:(NSDate *)createdDate{
    if(self = [super init]){
        _author = author;
        _channelKey = channelKey;
        _body = body;
        _createdDate = createdDate;
    }
    return self;
}

-(instancetype)initWithAuthor:(BCUser *)author
                   channelKey:(NSString *)channelKey
                         body:(NSString *)body{

    if(self = [self initWithAuthor:author
                        channelKey:channelKey
                              body:body
                       createdDate:[NSDate date]]){
    
    }
    return self;
}

-(NSDictionary *)json{
    NSDictionary *dict = @{@"author":[self.author json],
                           @"channelKey":self.channelKey,
                           @"body":self.body,
                           @"createdDate":self.createdDate.description};

    return dict;
}

+(BCMessage *)convertedToMessageFromJSON:(FIRDataSnapshot *)snapshot{
    NSDictionary *dataDict = snapshot.value;
    
    BCUser *author = [BCUser convertedFromJSON:[snapshot childSnapshotForPath:@"author"]];
    NSString *body = dataDict[@"body"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *createdDateDescription = dataDict[@"createdDate"];
    NSDate *createdDate = [dateFormatter dateFromString:createdDateDescription];
    
    NSString *channelKey = dataDict[@"channelKey"];
    
    BCMessage *message = [[BCMessage alloc] initWithAuthor:author channelKey:channelKey body:body createdDate:createdDate];
    return message;
}

+(NSArray <BCMessage *> *)convertedToMessagesFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *messages = [NSMutableArray new];
    for (FIRDataSnapshot *item in snapshot.children){
        BCMessage *message = [BCMessage convertedToMessageFromJSON:item];
        [messages addObject:message];
    }
    
    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(BCMessage *obj1, BCMessage * obj2) {
        return [obj2.createdDate compare:obj1.createdDate];
    }];
    
    return sortedMessages;
}

@end
