//
//  FIRStorageReference+Path.h
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <FirebaseStorage/FirebaseStorage.h>
#import "FIRDatabaseReference+Path.h"

typedef FIRStorageReference*(^BCStoragePathSectionBlock)(BCRefSection sect);
typedef FIRStorageReference*(^BCStoragePathUserBlock)(BCUser *user);
typedef FIRStorageReference*(^BCStoragePathItemBlock)(BCObject *item);
typedef FIRStorageReference*(^BCStoragePathChildBlock)(NSString *path);


@interface FIRStorageReference (Path)
@property(nonatomic, strong, readonly) BCStoragePathSectionBlock section;
@property(nonatomic, strong, readonly) BCStoragePathUserBlock user;
@property(nonatomic, strong, readonly) BCStoragePathItemBlock item;
@property(nonatomic, strong, readonly) BCStoragePathChildBlock child;

@end
