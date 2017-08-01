//
//  BCAvatar.m
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCAvatar.h"

@implementation BCAvatar

-(instancetype)initFromLocalWithUser:(BCUser *)user url:(NSString *)url{
    if(self = [super init]){
        _user = user;
        _url = url;
        _validKey = @"avatar";
        _createdTimeStamp = 0;
    }
    return self;
}

-(instancetype)initFromServerWithUser:(BCUser *)user
                                  url:(NSString *)url
                      createTimeStamp:(NSTimeInterval)createdTimeStamp
                             validKey:(NSString *)validKey{
    if(self = [super init]){
        _user = user;
        _url = url;
        _createdTimeStamp = createdTimeStamp;
        _validKey = validKey;
    }
    return self;
}

-(NSDictionary *)json{
    NSDictionary *dict = @{@"userKey":self.user.validKey,
                           @"url":self.url,
                           @"createTimeStamp":[FIRServerValue timestamp],
                           @"validKey":self.validKey};
    return dict;
}

+(BCAvatar *)convertedToAvatarFromJSON:(FIRDataSnapshot *)snapshot{
    NSDictionary *dataDict = snapshot.value;
    BCUser *user = [[BCUser alloc] initWithIdentity:dataDict[@"userKey"] andDisplayName:nil];
    NSString *url = dataDict[@"url"];
    NSNumber *createdTimeStamp = dataDict[@"createdTimeStamp"];
    NSString *validKey = dataDict[@"validKey"];
    
    BCAvatar *avatar = [[BCAvatar alloc] initFromServerWithUser:user
                                                            url:url
                                                createTimeStamp:createdTimeStamp.doubleValue validKey:validKey];
    return avatar;
}

@end
