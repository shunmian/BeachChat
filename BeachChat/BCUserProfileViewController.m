//
//  BCUserProfileViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/9.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCUserProfileViewController.h"
#import "BCChannelsTableViewController.h"

@interface BCUserProfileViewController ()

//chatManager
@property (nonatomic, strong) BCChatManager *chatManager;

//RACSignal
@property (nonatomic, strong) FIRDatabaseReference *userDisplayNameRef;
@property (nonatomic, strong) RACSignal *userDisplayNameSignal;

@property (nonatomic, strong) FIRDatabaseReference *friendRequestRef;
@property (nonatomic, strong) RACSignal *friendRequestStateSignal;

//RACSignal related views
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendFriendRequestBTN;
@property (weak, nonatomic) IBOutlet UIButton *waitFriendRequestBTN;
@property (weak, nonatomic) IBOutlet UIButton *friendRequestApprovedBTN;
@property (weak, nonatomic) IBOutlet UIButton *beingSentFriendRequestBTN;

@end

@implementation BCUserProfileViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sendFriendRequestBTNPressed:(id)sender {
    BCFriendRequest *request = [[BCFriendRequest alloc] initWithFrom:self.chatManager.bcUser to:self.user];
    [self.chatManager addFriendRequest:request];
}

- (IBAction)beingSentFriendRequestBTNPressed:(id)sender {
    BCFriendRequest *request = [[BCFriendRequest alloc] initWithFrom:self.chatManager.bcUser to:self.user];
    
    [self.chatManager acceptFriendRequest:request];
}

- (IBAction)friendRequestApprovedTBNPressed:(id)sender {
    FIRDatabaseReference *fromRef = [self.chatManager.channelRef child:[BCFriendRequest validKeyFrom:self.chatManager.bcUser to:self.user]];
    
    [fromRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if([snapshot.value isKindOfClass:[NSNull class]]){
            BCChannel *channel = [[BCChannel alloc] initFrom:self.chatManager.bcUser to:self.user];
            [fromRef setValue:[channel json]];
            [self.tabBarController setSelectedIndex:0];
        }else{
//            BCChannel *channel = [BCChannel convertedToChannelFromJSON:snapshot];
            FIRDataSnapshot *updatedSnapshot = [snapshot childSnapshotForPath:@"updatedDate"];
            [updatedSnapshot.ref setValue:[NSDate date].description];
            [self.tabBarController setSelectedIndex:0];
        }
    }];
}

#pragma mark - Navigation
/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toChannelsSegue"]){
        BCChannelsTableViewController *cstvc = segue.destinationViewController;
        [cstvc setUpWithEntryData:nil];
    }
}
*/
#pragma mark - 0 level setter & getter

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - FIRDatabaseRef

-(FIRDatabaseReference *)userDisplayNameRef{
    if(!_userDisplayNameRef){
        NSString *path = [NSString stringWithFormat:@"%@/%@",_user.validKey,@"displayName"];
        _userDisplayNameRef = [self.chatManager.userRef child:path];
    }
    return _userDisplayNameRef;
}


-(FIRDatabaseReference *)friendRequestRef{
    if(!_friendRequestRef){
        NSString *path = [NSString stringWithFormat:@"%@",[BCFriendRequest validKeyFrom:self.chatManager.bcUser to:_user]];
        _friendRequestRef = [self.chatManager.friendRequestRef child:path];
    }
    return _friendRequestRef;
}


#pragma mark - RACSignal

-(RACSignal *)createUserDisplayNameSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.userDisplayNameRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            [subscriber sendNext:snapshot.value];
        }];
        return [RACDisposable disposableWithBlock:^{
             NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(RACSignal *)createFriendRequestSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendRequestRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if([snapshot.value isKindOfClass:[NSNull class]]){
                BCFriendRequest *request = [[BCFriendRequest alloc] initWithFrom:self.chatManager.bcUser to:self.user];
                [subscriber sendNext:request];
            }else{
                BCFriendRequest *request = [BCFriendRequest convertedFromJSON:snapshot];
                [subscriber sendNext:request];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

# pragma mark - helper

-(void)setUpSignals{
    
    self.userDisplayNameSignal = [self createUserDisplayNameSignal];
    [[self createUserDisplayNameSignal] subscribeNext:^(id x) {
        self.displayNameLabel.text = x;
    }];
    
    self.friendRequestStateSignal = [[self createFriendRequestSignal]
                                     map:^NSNumber *(BCFriendRequest *request) {
                                         BCFriendRequestState state = request.state;
                                         if(state == BCFriendRequestStateApplied && [request isSender:self.user]){
                                             return @(BCFriendRequestStateBeingApplied);
                                         }else{
                                             return @(state);
                                         }
                                     }];
    [self.friendRequestStateSignal subscribeNext:^(NSNumber *x) {
          NSInteger state = x.integerValue;
          switch (state) {
              case BCFriendRequestStateNoteApplied:
                  self.sendFriendRequestBTN.hidden = NO;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.beingSentFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateApplied:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = NO;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.beingSentFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateAccepted:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = NO;
                  self.beingSentFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateBeingApplied:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.beingSentFriendRequestBTN.hidden = NO;
              default:
                  break;
          }
      }];
}

-(void)initializeViews{
    self.sendFriendRequestBTN.hidden = YES;
    self.waitFriendRequestBTN.hidden = YES;
    self.friendRequestApprovedBTN.hidden = YES;
    self.beingSentFriendRequestBTN.hidden = YES;
}

#pragma mark - Public Method
-(void)setUpWithEntryData:(id)data{
    NSAssert([data isKindOfClass:[BCUser class]], @"data must to BCUser Class");
    self.user = data;
    [self initializeViews];
    [self setUpSignals];
}

@end
