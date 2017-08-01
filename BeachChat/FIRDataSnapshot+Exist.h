//
//  FIRDataSnapshot+Exist.h
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <FirebaseDatabase/FirebaseDatabase.h>

@interface FIRDataSnapshot (Exist)
-(BOOL)isValueExist;
@end
