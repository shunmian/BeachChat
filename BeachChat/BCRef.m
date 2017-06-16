//
//  BCRef.m
//  BeachChat
//
//  Created by LAL on 2017/6/15.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCRef.h"

@implementation BCRef



+(void)initialize{
    if(!root){
        root = [[FIRDatabase database] reference];
    }
    if(!storage){
        storage = [[FIRStorage storage] referenceForURL:kAppURL];
    }
}

+(FIRDatabaseReference *)root{
    return root;
}

+(FIRStorageReference *)storage{
    return storage;
}

@end
