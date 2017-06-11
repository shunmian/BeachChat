//
//  FIRUser+User.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <FirebaseAuth/FirebaseAuth.h>
#import "BCUser.h"

@interface FIRUser (User)
@property(nonatomic, copy) NSString *identity;
-(BCUser *)convertToBCUser;
@end
