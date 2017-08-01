//
//  BCChannelsTableViewController.m
//  
//
//  Created by LAL on 2017/6/8.
//
//

#import "BCChannelsTableViewController.h"
#import "BCChannelViewController.h"
#import "BCChannel.h"
#import "BCChannelTableViewCell.h"

@interface BCChannelsTableViewController ()
@property (nonatomic, strong) BCChatManager *chatManager;
@property (nonatomic, strong) NSMutableArray <BCChannel *> *channels;
@property (nonatomic, strong) RACSignal *channelsSignal;
@property (nonatomic, strong) FIRDatabaseReference *channelsRef;
@end

@implementation BCChannelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 70;
    self.tabBarItem.title = @"BeachChat";
    self.navigationItem.title = self.tabBarItem.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toChannelSegue"]){
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        BCChannel *channel = self.channels[indexPath.row];
        BCChannelViewController *cvc = segue.destinationViewController;
        [cvc setUpWithEntryData:channel];
    }
}


#pragma mark - 0 level Setter & Getter
-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - oteher Setter & Getter
-(FIRDatabaseReference *)channelsRef{
    if(!_channelsRef){
        _channelsRef = self.chatManager.channelsRef;
    }
    return _channelsRef;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
    BCChannel *channel = self.channels[indexPath.row];
    
    cell.avartarView.image = [UIImage imageNamed:@"defaultUserAvatar"];
    if(channel.unreadMessageNumber == 0){
        cell.lastMessageBodyLabel.text =  channel.lastMessage ? [NSString stringWithFormat:@"%@:%@",channel.lastMessage.author.displayName,channel.lastMessage.body]:nil;
    }else{
        cell.lastMessageBodyLabel.text = channel.lastMessage ? [NSString stringWithFormat:@"[%ld条] %@:%@",(long)channel.unreadMessageNumber,channel.lastMessage.author.displayName,channel.lastMessage.body]:nil;
    }
    cell.unreadMessageNotificationView.hidden = channel.unreadMessageNumber == 0? YES:NO;
    cell.updatedDateLabel.text = [NSDate toStringFromTimeInterval:channel.updatedTimeStamp];
    cell.nameLabel.text = [channel otherOf:self.chatManager.bcUser].displayName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toChannelSegue" sender:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

#pragma mark - RACSignal

-(RACSignal *)createChannelsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.channelsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *channels = [[BCChannel convertedToChannelsFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:channels];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

#pragma mark - Helper

-(void)setUpSignals{
    self.channelsSignal = [self createChannelsSignal];
    [self.channelsSignal subscribeNext:^(NSMutableArray *channels) {
        self.channels = channels;
        [self.tableView reloadData];
    }];
}

#pragma mark - Public Method

-(void)setUpWithEntryData:(id)data{
    [self setUpSignals];
}


-(RACSignal *)createUnreadMessageNumberSignalForChannel:(BCChannel *)channel{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRDatabaseReference *ref = BCRef.root.section(BCRefChannelsSection).user(self.chatManager.bcUser).child(channel.validKey).child(@"unreadMessageNumber");
        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(![snapshot isValueExist]){
                [subscriber sendNext:@(0)];
            }else{
                NSNumber *unreadMessageNumber = snapshot.value;
                [subscriber sendNext:unreadMessageNumber];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
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
