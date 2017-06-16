//
//  BCUserListTableViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/9.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCUsersTableViewController.h"
#import "BCUserProfileViewController.h"

@interface BCUsersTableViewController ()
@property (nonatomic, strong) BCChatManager *chatManager;
@property (nonatomic, strong) NSMutableArray <BCUser *> *users;
@property (nonatomic, strong) FIRDatabaseReference *usersSectionRef;
@end

@implementation BCUsersTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 0 level setter & getter

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - other setter & getter

-(FIRDatabaseReference *)usersSectionRef{
    if(!_usersSectionRef){
        _usersSectionRef = self.chatManager.usersSectionRef;
    }
    return _usersSectionRef;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    
    BCUser *user = self.users[indexPath.row];
    cell.textLabel.text = user.displayName;
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"toUserProfileSegue" sender:indexPath];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    BCUserProfileViewController *upvc = [segue destinationViewController];
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    BCUser *user = self.users[indexPath.row];
    [upvc setUpWithEntryData:user];
}


#pragma mark - RACSignal

-(RACSignal *)createUsersSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.usersSectionRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSArray *users = [BCUser convertedToUsersFromJSONs:snapshot];
            [subscriber sendNext:[users mutableCopy]];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

#pragma mark - public method

-(void)setUpSignals{
    [[self createUsersSignal] subscribeNext:^(NSMutableArray *users) {
        self.users = users;
        [self.tableView reloadData];
    }];
}

-(void)setUpWithEntryData:(id)data{
    [self setUpSignals];
}


@end
