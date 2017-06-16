//
//  BCFriendCategoryTableViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/9.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCFriendCategoryTableViewController.h"
#import "BCFriendsTableViewController.h"
#import "BCFriendRequestsTableViewController.h"
#import "BCUsersTableViewController.h"


typedef NS_ENUM(NSUInteger,BCFriendCategoryIndex){
    BCFriendCategoryIndexFriendList = 0,
    BCFriendCategoryIndexFriendRequestList,
    BCFriendCategoryIndexFriendAddingList,
};

@interface BCFriendCategoryTableViewController ()
@property (nonatomic, strong) NSArray *friendsCategory;
@end

@implementation BCFriendCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.title = @"Friend";
    self.navigationItem.title = self.tabBarItem.title;
}

-(NSArray *)friendsCategory{
    if(!_friendsCategory){
        _friendsCategory = @[@"现有好友",@"好友请求",@"添加好友"];
    }
    return _friendsCategory;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsCategory.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCategoryCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.friendsCategory[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case BCFriendCategoryIndexFriendList:
            [self performSegueWithIdentifier:@"toFriendsSegue" sender:self];
            break;
        case BCFriendCategoryIndexFriendRequestList:
            [self performSegueWithIdentifier:@"toFriendRequestsSegue" sender:self];
            break;
            
        case BCFriendCategoryIndexFriendAddingList:
            [self performSegueWithIdentifier:@"toUsersSegue" sender:self];
            break;
            
        default:
            break;
    }
}



//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    if([segue.identifier isEqualToString:@"toFriendRequestListSegue"]){
//        BCFriendRequestListTableViewController *frltvc = (BCFriendRequestListTableViewController *)segue.destinationViewController;
//    }
//    
//}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"toFriendsSegue"]){
        BCFriendsTableViewController *fstvc = segue.destinationViewController;
        [fstvc setUpWithEntryData:nil];
    }else if([segue.identifier isEqualToString:@"toUsersSegue"]){
        BCUsersTableViewController *userstvc = segue.destinationViewController;
        [userstvc setUpWithEntryData:nil];
    }else if([segue.identifier isEqualToString:@"toFriendRequestsSegue"]){
        BCFriendRequestsTableViewController *frstvc = segue.destinationViewController;
        [frstvc setUpWithEntryData:nil];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
