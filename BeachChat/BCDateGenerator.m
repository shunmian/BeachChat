//
//  BCDateGenerator.m
//  
//
//  Created by LAL on 2017/6/11.
//
//

#import "BCDateGenerator.h"

@interface BCDateGenerator()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) RACSignal *serverTimeSignal;
@property(nonatomic, strong) FIRDatabaseReference *timeRef;
@end

@implementation BCDateGenerator

#pragma mark - 0 Level Setter & Getter

+(instancetype)sharedGenerator{
    static BCDateGenerator *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BCDateGenerator alloc] init];
    });
    return _sharedManager;
}

-(instancetype)init{
    if(self = [super init]){
        [self startMonitor];
    }
    return self;
}

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

-(FIRDatabaseReference *)timeRef{
    if(!_timeRef){
        _timeRef = self.chatManager.timeRef;
    }
    return _timeRef;
}

-(void)startMonitor{
    [self.timeRef setValue:[FIRServerValue timestamp]];
    [self.timeRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTimeInterval t = (NSTimeInterval)[snapshot.value integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];
        NSLog(@"date:%@",date);
    }];
}



@end
