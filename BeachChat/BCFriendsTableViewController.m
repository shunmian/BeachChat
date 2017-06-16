//
//  BCFriendsTableViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/11.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCFriendsTableViewController.h"
#import "BCUserProfileViewController.h"

@interface BCFriendsTableViewController ()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) NSMutableArray <BCUser *>* friends;
@property(nonatomic, strong) FIRDatabaseReference *friendsRef;
@property(nonatomic, strong) RACSignal *friendsSignal;
@end

@implementation BCFriendsTableViewController

#pragma mark - 1_Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - 2_Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toUserProfileSegue"]){
        BCUserProfileViewController *upvc = (BCUserProfileViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        BCUser *fromUser = self.friends[indexPath.row];
        [upvc setUpWithEntryData:fromUser];
    }
}

#pragma mark - 3.1_0 level Setter & Getter

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - 3.2_Other Settter & Getter

-(FIRDatabaseReference *)friendsRef{
    if(!_friendsRef){
        _friendsRef = self.chatManager.friendsRef;
    }
    return _friendsRef;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 4_Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    BCUser *friend = self.friends[indexPath.row];
    cell.textLabel.text = friend.displayName;    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toUserProfileSegue" sender:indexPath];

}


#pragma mark - 5_RACSignal

-(RACSignal *)createFriendsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *friends = [[BCUser convertedToUsersFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:friends];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

#pragma mark - 6_Helper

-(void)setUpSignals{
    self.friendsSignal = [self createFriendsSignal];
    [self.friendsSignal subscribeNext:^(NSMutableArray *friends) {
        self.friends = friends;
        [self.tableView reloadData];
    }];
}

#pragma mark - 7_Public Method

-(void)setUpWithEntryData:(id)data{
    [self setUpSignals];
}

@end
