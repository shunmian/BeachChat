//
//  FIRDataSnapshot+Exist.m
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "FIRDataSnapshot+Exist.h"

@implementation FIRDataSnapshot (Exist)
-(BOOL)isValueExist{
    if([self.value isKindOfClass:[NSNull class]]){
        return NO;
    }else{
        return YES;
    }
}
@end
