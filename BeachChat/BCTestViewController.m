//
//  BCTestViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/9.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCTestViewController.h"

@interface BCTestViewController ()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) BCUser *toUser;
@property(nonatomic, copy) FIRDatabaseReference *friendRequestStateRef;
@end

@implementation BCTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[FIRAuth auth] signInWithEmail:@"112447070@qq.com" password:@"1234567" completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            NSLog(@"sign in successful");
            self.chatManager.firUser = user;
            self.chatManager.firUser.identity = @"112447070@qq.com";
        }else{
            NSLog(@"sign in fail");
        }
    }];
    

    
//    [self friendRequestStateSignalFrom:self.chatManager.bcUser to:self.]

    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

-(FIRDatabaseReference *)friendRequestStateRef{
    NSString *path = [NSString stringWithFormat:@"%@/%@",[BCFriendRequest validKeyFrom: self.chatManager.bcUser to:self.toUser],@"state"];
    FIRDatabaseReference *testFriendRequestRef = [self.chatManager.friendRequestRef child:path];
    return testFriendRequestRef;
}

- (IBAction)getToUserBTNPressed:(id)sender {
    [self.chatManager getUserWithIdentity:@"shunmian@gmail.com" withCompletion:^(BCUser *user, NSError *error) {
        if(!error){
            NSLog(@"get to user success: %@",user);
            self.toUser = user;
            [[self friendRequestStateSignalFrom:self.chatManager.bcUser to:self.toUser] subscribeNext:^(id x) {
                NSLog(@"state: %@",x);
            }];
        }else{
            NSLog(@"get to user error: %@",[error localizedDescription]);
        }
    }];
}



- (IBAction)addStateSignalBTNPressed:(id)sender {
    [[self friendRequestStateSignalFrom:self.chatManager.bcUser to:self.toUser] subscribeNext:^(NSNumber *state) {
        NSInteger stateInt = [state integerValue];
        switch (stateInt) {
            case BCFriendRequestStateNoteApplied:
                NSLog(@"BCFriendRequestStateNoteApplied");
                break;
            case BCFriendRequestStateApplied:
                NSLog(@"BCFriendRequestStateApplied");
                break;
            case BCFriendRequestStateAccepted:
                NSLog(@"BCFriendRequestStateAccepted");
                break;
            case BCFriendRequestStateFinished:
                NSLog(@"BCFriendRequestStateFinished");
                break;
            default:
                break;
        }
    }];
}

- (IBAction)addBTNPressed:(id)sender {

//    [self.chatManager addFriendRequestFrom:self.chatManager.bcUser to:self.toUser];
//    [self.testRef setValue:@"1"];
}

- (IBAction)acceptBTNPressed:(id)sender {
    [self.friendRequestStateRef setValue:@(BCFriendRequestStateAccepted)];
}

- (IBAction)removeBTNPressed:(id)sender {
//    [self.testRef setValue:nil];
    [self.chatManager deleteFriendRequestFrom:self.chatManager.bcUser to:self.toUser];
}

-(RACSignal *)friendRequestStateSignalFrom:(BCUser *)from to:(BCUser *)to{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendRequestStateRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSNumber *state = snapshot.value;
            [subscriber sendNext:state];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"state signal disposed");
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
