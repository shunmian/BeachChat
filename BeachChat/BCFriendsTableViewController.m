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
@property(nonatomic, strong) FIRDatabaseReference *friendRequestRef;
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

-(FIRDatabaseReference *)friendRequestRef{
    if(!_friendRequestRef){
        _friendRequestRef = self.chatManager.friendRequestRef;
    }
    return _friendRequestRef;
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
        [self.friendRequestRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *friends = [[BCFriendRequest convertedToFriendsFromJSONs:snapshot user:self.chatManager.bcUser] mutableCopy];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
