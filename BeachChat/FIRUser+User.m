//
//  FIRUser+User.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "FIRUser+User.h"
#import <objc/runtime.h>

@implementation FIRUser (User)

-(void)setIdentity:(NSString *)identity{
    objc_setAssociatedObject(self, @selector(identity), identity, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)identity{
    return objc_getAssociatedObject(self, @selector(identity));
}

-(BCUser *)convertToBCUser{
    BCUser *user = [[BCUser alloc] initWithIdentity:self.identity andDisplayName:self.displayName];
    return user;
}
@end
