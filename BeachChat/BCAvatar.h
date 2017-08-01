//
//  BCAvatar.h
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCAvatar : NSObject
@property(nonatomic, strong) BCUser *user;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, assign) NSTimeInterval createdTimeStamp;
@property(nonatomic, strong, readonly) NSString *validKey;

-(instancetype)initFromLocalWithUser:(BCUser *)user
                                 url:(NSString *)url;

-(instancetype)initFromServerWithUser:(BCUser *)user
                                  url:(NSString *)url
                      createTimeStamp:(NSTimeInterval)createdTimeStamp
                             validKey:(NSString *)validKey;


-(NSDictionary *)json;
+(BCAvatar *)convertedToAvatarFromJSON:(FIRDataSnapshot *)snapshot;
@end
