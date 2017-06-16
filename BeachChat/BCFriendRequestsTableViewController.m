//
//  BCFriendRequestListTableViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/10.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCFriendRequestsTableViewController.h"
#import "BCUserProfileViewController.h"

@interface BCFriendRequestsTableViewController ()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) NSMutableArray<BCFriendRequest *> *friendRequests;
@property(nonatomic, strong) FIRDatabaseReference *friendRequestsRef;
@property(nonatomic, strong) RACSignal *friendRequestsSignal;
@end

@implementation BCFriendRequestsTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toUserProfileSegue"]){
        BCUserProfileViewController *upvc = (BCUserProfileViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        BCUser *fromUser = self.friendRequests[indexPath.row].from;
        [upvc setUpWithEntryData:fromUser];
    }
}

#pragma mark - 0 level setter & getter

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - other setter & getter

-(NSMutableArray<BCFriendRequest *> *)friendRequests{
    if(!_friendRequests){
        _friendRequests = [NSMutableArray new];
    }
    return _friendRequests;
}

-(FIRDatabaseReference *)friendRequestsRef{
    if(!_friendRequestsRef){
        _friendRequestsRef = self.chatManager.friendRequestsRef;
    }
    return _friendRequestsRef;
}

#pragma mark - RACSignal

-(RACSignal *)createFriendRequestsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.friendRequestsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *friendRequests = [[BCFriendRequest convertedToFriendRequestsFromJSONs:snapshot receiver:self.chatManager.bcUser] mutableCopy];
            [subscriber sendNext:friendRequests];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendRequests.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequestCell" forIndexPath:indexPath];
    BCFriendRequest *friendRequest = self.friendRequests[indexPath.row];
    BCUser *other = [friendRequest otherOf:self.chatManager.bcUser];
    cell.textLabel.text = other.displayName;
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toUserProfileSegue" sender:indexPath];
}

#pragma mark - Public Method

-(void)setUpSignals{
    self.friendRequestsSignal = [self createFriendRequestsSignal];
    [self.friendRequestsSignal subscribeNext:^(id x) {
        self.friendRequests = x;
        [self.tableView reloadData];
    }];
}

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
