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

@interface BCChannelsTableViewController ()
@property (nonatomic, strong) BCChatManager *chatManager;

@property (nonatomic, strong) NSMutableArray <BCChannel *> *channels;
@property (nonatomic, strong) RACSignal *channelsSignal;
@property (nonatomic, strong) FIRDatabaseReference *channelRef;
@end

@implementation BCChannelsTableViewController

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
-(FIRDatabaseReference *)channelRef{
    if(!_channelRef){
        _channelRef = self.chatManager.channelRef;
    }
    return _channelRef;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
    BCChannel *channel = self.channels[indexPath.row];
    cell.textLabel.text = channel.displayName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toChannelSegue" sender:indexPath];
}

#pragma mark - RACSignal

-(RACSignal *)createChannelsSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.channelRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
