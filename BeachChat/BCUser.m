//
//  BCUser.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCUser.h"

@implementation BCUser
-(instancetype)initWithIdentity:(NSString *)identity
                 andDisplayName:(NSString *)displayName{
    if(self = [super init]){
        _identity = identity;
        _validKey = [_identity stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        if(!displayName){
            _displayName = identity;
        }else{
            _displayName = displayName;
        }
    }
    return self;
}


-(NSDictionary *)json{
    NSDictionary *dict = @{@"identity":self.identity,
                           @"displayName":self.displayName};
    return dict;
}

+(NSString *)validKeyFromIdentity:(NSString *)identity{
    return [identity stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

+(BCUser *)convertedFromJSON:(FIRDataSnapshot *)snapshot{
    return [[BCUser alloc] initWithIdentity:snapshot.value[@"identity"] andDisplayName:snapshot.value[@"displayName"]];
}

+(NSArray<BCUser *>*)convertedFromJSONs:(FIRDataSnapshot *)snapshot{
    NSMutableArray *users = [NSMutableArray new];
    for(FIRDataSnapshot *item in snapshot.children.allObjects){
        BCUser *user = [BCUser convertedFromJSON:item];
        [users addObject:user];
    }
    return [NSArray arrayWithArray:users] ;
}

-(BOOL)isEqual:(id)object{
    NSAssert([object isKindOfClass:[BCUser class]], @"object should be BCUseer class");
    BCUser *other = (BCUser *)object;
    return [self.validKey isEqualToString:other.validKey];
}

@end
