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
@property (nonatomic, strong) FIRDatabaseReference *friendsRef;
@property (nonatomic, strong) RACSignal *friendRequestStateSignal;

//RACSignal related views
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendFriendRequestBTN;
@property (weak, nonatomic) IBOutlet UIButton *waitFriendRequestBTN;
@property (weak, nonatomic) IBOutlet UIButton *friendRequestApprovedBTN;
@property (weak, nonatomic) IBOutlet UIButton *acceptFriendRequestBTN;

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

- (IBAction)acceptFriendRequestBTNPressed:(id)sender {
    BCFriendRequest *request = [[BCFriendRequest alloc] initWithFrom:self.chatManager.bcUser to:self.user];
    
    [self.chatManager acceptFriendRequest:request];
}

- (IBAction)friendRequestApprovedTBNPressed:(id)sender {
    FIRDatabaseReference *fromRef = [self.chatManager.channelsRef child:[BCFriendRequest validKeyFrom:self.chatManager.bcUser to:self.user]];
    
    [fromRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if([snapshot.value isKindOfClass:[NSNull class]]){
            BCChannel *channel = [[BCChannel alloc] initFrom:self.chatManager.bcUser to:self.user];
            [fromRef setValue:[channel json]];
            [self.tabBarController setSelectedIndex:0];
        }else{
//            BCChannel *channel = [BCChannel convertedToChannelFromJSON:snapshot];
            FIRDataSnapshot *updatedSnapshot = [snapshot childSnapshotForPath:@"updatedDate"];
            [updatedSnapshot.ref setValue:[FIRServerValue timestamp] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if(!error){
                    [self.tabBarController setSelectedIndex:0];
                    UINavigationController *navc = self.tabBarController.viewControllers[0];
                    BCChannelsTableViewController *ctvc =  navc.viewControllers[0];
                    [ctvc.tableView reloadData];
                    [ctvc tableView:ctvc.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                }
            }];

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
        _userDisplayNameRef = self.chatManager.usersSectionRef.user(self.user).child(@"displayName");
    }
    return _userDisplayNameRef;
}


-(FIRDatabaseReference *)friendRequestRef{
    if(!_friendRequestRef){
        _friendRequestRef = self.chatManager.friendRequestsRef.child([BCFriendRequest validKeyFrom:self.chatManager.bcUser to:_user]);
    }
    return _friendRequestRef;
}

-(FIRDatabaseReference *)friendsRef{
    if(!_friendsRef){
        _friendsRef = self.chatManager.friendsRef;
    }
    return _friendsRef;
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
            BCFriendRequest *request = [BCFriendRequest convertedToUserFromJSON:snapshot];
            [subscriber sendNext:request];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(RACSignal *)createFriendSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendsRef.child(self.user.validKey) observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            BCUser *user = [BCUser convertedToUserFromJSON:snapshot];
            [subscriber sendNext:user];
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
    
    RACSignal *friendRequstSignal = [self createFriendRequestSignal];
    RACSignal *friendSignal = [self createFriendSignal];
    
    self.friendRequestStateSignal = [RACSignal combineLatest:@[friendSignal,friendRequstSignal] reduce:^id(BCUser *user,BCFriendRequest *friendRequest){
        
        if ([user isEqual:self.user]) return @(BCFriendRequestStateAccepted);
        if (friendRequest.state == BCFriendRequestStateApplied && ![friendRequest.from isEqual:self.chatManager.bcUser])return @(BCFriendRequestStateBeingApplied);
        return @(friendRequest.state);
    }];
    
    [self.friendRequestStateSignal subscribeNext:^(NSNumber *x) {
          NSInteger state = x.integerValue;
          switch (state) {
              case BCFriendRequestStateNoteApplied:
                  self.sendFriendRequestBTN.hidden = NO;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.acceptFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateApplied:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = NO;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.acceptFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateAccepted:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = NO;
                  self.acceptFriendRequestBTN.hidden = YES;
                  break;
              case BCFriendRequestStateBeingApplied:
                  self.sendFriendRequestBTN.hidden = YES;
                  self.waitFriendRequestBTN.hidden = YES;
                  self.friendRequestApprovedBTN.hidden = YES;
                  self.acceptFriendRequestBTN.hidden = NO;
              default:
                  break;
          }
      }];
}

-(void)initializeViews{
    self.sendFriendRequestBTN.hidden = YES;
    self.waitFriendRequestBTN.hidden = YES;
    self.friendRequestApprovedBTN.hidden = YES;
    self.acceptFriendRequestBTN.hidden = YES;
}

#pragma mark - Public Method
-(void)setUpWithEntryData:(id)data{
    NSAssert([data isKindOfClass:[BCUser class]], @"data must to BCUser Class");
    self.user = data;
    [self initializeViews];
    [self setUpSignals];
}

@end
