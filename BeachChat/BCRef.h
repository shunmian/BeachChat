//
//  BCRef.h
//  BeachChat
//
//  Created by LAL on 2017/6/15.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

static FIRDatabaseReference *root = nil;
static FIRStorageReference *storage = nil;
static NSString *const kAppURL = @"gs://beachchat-b169a.appspot.com/";

@interface BCRef : NSObject
+(FIRDatabaseReference *)root;
+(FIRStorageReference *)storage;
@end
