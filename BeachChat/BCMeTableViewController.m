//
//  BCMeTableViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMeTableViewController.h"
#import "BCMeInfoAvatarTableViewCell.h"
#import "BCMeDisplayNameViewController.h"
#import "BCMeAvatarViewController.h"

static NSString *const kAvatarCell = @"meInfoAvatarCell";
static NSString *const kDisplayNameCell = @"meInfoDisplayNameCell";

@interface BCMeTableViewController ()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) BCUser *user;
@property(nonatomic, strong) NSMutableArray *info;
@property(nonatomic, strong) RACSignal *displayNameSignal;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) RACSignal *avatarURLSignal;
@property(nonatomic, strong) UIImage *avatarImage;
@end

@implementation BCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.info addObject:@"Avatar"];
    [self.info addObject:@"displayName"];
    self.navigationItem.title = @"Me";
    [self setUpWithEntryData:nil];
    
    [self.avatarURLSignal subscribeNext:^(NSString *url) {
        if(!url){
            self.avatarImage = [UIImage imageNamed:@"defaultUserAvatar"];
        }else{
            NSLog(@"image url is :%@",url);
            [self.chatManager fetchImageDataAtURL:url withComletion:^(UIImage *image, NSError *error) {
                if(!error){
                    self.avatarImage = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }];
        }
    }];
    
    [self.displayNameSignal subscribeNext:^(NSString *displayName) {
        self.displayName = displayName;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
//    [self.tableView registerClass:[BCMeInfoAvatarTableViewCell class] forCellReuseIdentifier:kAvatarCell];
//    [self.tableView registerClass:[BCMeInfoDisplayNameTableViewCell class] forCellReuseIdentifier:kDisplayNameCell];
    
//    self.tableView.separatorColor = [UIColor blueColor];
//    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"toAvatarSegue"]){
        BCMeAvatarViewController *avc = segue.destinationViewController;
        [avc setUpWithEntryData:nil];
    }else if([segue.identifier isEqualToString:@"toDisplayNameSegue"]){
        BCMeDisplayNameViewController *dnvc = segue.destinationViewController;
        [dnvc setUpWithEntryData:self.chatManager.bcUser.displayName];//change
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

-(BCUser *)user{
    if(!_user){
        _user = self.chatManager.bcUser;
    }
    return _user;
}

-(NSMutableArray *)info{
    if(!_info){
        _info = [NSMutableArray new];
    }
    return _info;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.info.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCMeInfoAvatarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAvatarCell forIndexPath:indexPath];

    if(indexPath.section == 0 && indexPath.row == 0){
        cell.avatarView.hidden = NO;
        cell.displayNameLabel.hidden = YES;
        cell.avatarView.image = [UIImage imageNamed:@"defaultUserAvatar"];
        cell.itemLabel.text = self.info[indexPath.row];
        cell.avatarView.image = self.avatarImage;
    }else if(indexPath.section == 0 && indexPath.row == 1){
        cell.itemLabel.text = self.info[indexPath.row];
        cell.avatarView.hidden = YES;
        cell.displayNameLabel.hidden = NO;
        cell.displayNameLabel.text = self.displayName;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 120;
    }else if (indexPath.row == 1){
        return 60;
    }else{
        return 30;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"toAvatarSegue" sender:self];
    }else if(indexPath.section == 0 && indexPath.row == 1){
        [self performSegueWithIdentifier:@"toDisplayNameSegue" sender:self];
    }

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
-(RACSignal *)createDisplayNameSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRDatabaseReference *displayNameRef = BCRef.root.section(BCRefUsersSection).user(self.chatManager.bcUser).child(@"displayName");
        [displayNameRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(![snapshot isValueExist]){
                [subscriber sendNext:nil];
            }else{
                NSString *displayName = snapshot.value;
                [subscriber sendNext:displayName];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(RACSignal *)createAvatarURLSignal{
    FIRDatabaseReference *ref = BCRef.root.section(BCRefUsersSection).user(self.chatManager.bcUser).child(@"avatar").child(@"url");
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(![snapshot isValueExist] || [snapshot.value isEqualToString:@"NOTSET"]){
                [subscriber sendNext:nil];
            }else{
                NSString *url = snapshot.value;
                [subscriber sendNext:url];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
    
}



-(void)setUpSignals{
    self.displayNameSignal = [self createDisplayNameSignal];
    self.avatarURLSignal = [self createAvatarURLSignal] ;
}

-(void)setUpWithEntryData:(id)data{
    [self setUpSignals];
}

@end
