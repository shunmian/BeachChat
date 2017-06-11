//
//  BCChannelViewController.m
//  
//
//  Created by LAL on 2017/6/11.
//
//

#import "BCChannelViewController.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessage.h"
#import "UIColor+JSQMessages.h"
#import "JSQSystemSoundPlayer.h"
#import "JSQSystemSoundPlayer+JSQMessages.h"


@interface BCChannelViewController ()

//Static Entry Data
@property(nonatomic, strong) BCChannel *channel;

//Shared Manager
@property(nonatomic, strong) BCChatManager *chatManager;

//Messages
@property(nonatomic, strong) NSMutableArray <BCMessage *>* messages;
@property(nonatomic, strong) FIRDatabaseReference *channelMessagesRef;
@property(nonatomic, strong) RACSignal *messagesSignal;

//Views
@property(nonatomic, strong) JSQMessagesBubbleImage *outgointBubbleImageView;
@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;
@property(nonatomic, weak) UITextView *inputTextView;

@end

@implementation BCChannelViewController

#pragma mark - 0_Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didPressSendButton:(UIButton *)button
          withMessageText:(NSString *)text
                 senderId:(NSString *)senderId
        senderDisplayName:(NSString *)senderDisplayName
                     date:(NSDate *)date{
    NSLog(@"return pressed");
    
    
    if(text.length == 0){
        [self.view endEditing:YES];
    }else{
        BCMessage *message =[[BCMessage alloc] initWithAuthor:self.chatManager.bcUser
                                                   channelKey:self.channel.validKey
                                                         body:text];
        FIRDatabaseReference *ref = [self.channelMessagesRef childByAutoId];
        [ref setValue:[message json] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if(!error){
                NSLog(@"message sent successfully:%@",message);
                BCUser *otherUser = [self.channel otherOf:self.chatManager.bcUser];
                FIRDatabaseReference *toParentChannelRef = [self.chatManager.channelRef.parent child:otherUser.validKey];
                
                FIRDatabaseReference *toChannelRef = [toParentChannelRef child:[BCFriendRequest validKeyFrom:self.chatManager.bcUser to:otherUser]];
                
                [toChannelRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    if([snapshot.value isKindOfClass:[NSNull class]]){
                        // if toUser don't have this channel, creat it, then add the message
                        [toChannelRef setValue:[self.channel json]];
                    }else{
                        
                    }
                }];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }else{
                NSLog(@"message not sent...");
            }
         
         
            self.inputTextView.text= @"";
            [self finishSendingMessage];
            [self scrollToBottomAnimated:YES];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        }];
    }
    
}

#pragma mark - 1_Navigation


#pragma mark - 2.1_0 Level Setter & Getter

-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}


#pragma mark - 2.2_other Setter & Getter

-(UITextView *)inputTextView{
    if(!_inputTextView){
        _inputTextView = self.inputToolbar.contentView.textView;
        _inputTextView.delegate = self;
    }
    return _inputTextView;
}

-(FIRDatabaseReference *)channelMessagesRef{
    if(!_channelMessagesRef){
        _channelMessagesRef = [self.chatManager.messageRef child:self.channel.validKey];
    }
    return _channelMessagesRef;
}

-(JSQMessagesBubbleImage *)outgointBubbleImageView{
    if(!_outgointBubbleImageView){
        _outgointBubbleImageView = [self setupOutgoingBubble];
    }
    return _outgointBubbleImageView;
}

-(JSQMessagesBubbleImage *)incomingBubbleImageView{
    if(!_incomingBubbleImageView){
        _incomingBubbleImageView = [self setupIncomingBubble];
    }
    return _incomingBubbleImageView;
}


#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    BCMessage *bcMessage;
    if(collectionView == self.collectionView){
        bcMessage  = (BCMessage *)self.messages[indexPath.row];
    }
//    else if(collectionView == self.resultController.collectionView){
//        tcMessage  = (TCMessage *)self.searchedMessages[indexPath.row];
//    }
    return [self convertFromBCMessageToJSQMessageData:bcMessage];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count;
    if(collectionView == self.collectionView){
        count = self.messages.count;
    }
//    else if(collectionView == self.resultController.collectionView){
//        count = self.searchedMessages.count;
//    }
    return count;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message;
    if(collectionView == self.collectionView){
        message = [self convertFromBCMessageToJSQMessageData: self.messages[indexPath.row]];
    }
//    else if (collectionView == self.resultController.collectionView){
//        message = [self convertFromTCMessageToJSQMessageData: self.searchedMessages[indexPath.row]];
//    }
    if ([message.senderId isEqualToString: self.senderId]){
        return self.outgointBubbleImageView;
    }else{
        return self.incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message;
    if(collectionView == self.collectionView){
        message = [self convertFromBCMessageToJSQMessageData: self.messages[indexPath.row]];
    }
//    else if (collectionView == self.resultController.collectionView){
//        message = [self convertFromTCMessageToJSQMessageData: self.searchedMessages[indexPath.row]];
//    }
    if ([message.senderId isEqualToString:self.senderId]){
        cell.textView.textColor = [UIColor whiteColor];
    }else{
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - RACSignal

-(RACSignal *)createMessageSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.channelMessagesRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *messages = [[BCMessage convertedToMessagesFromJSONs:snapshot] mutableCopy];;
            [subscriber sendNext:messages];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)setUpSignals{
    self.messagesSignal = [self createMessageSignal];
    [self.messagesSignal subscribeNext:^(NSMutableArray *messages) {
        self.messages = messages;
        [self.collectionView reloadData];
    }];
}

-(void)setUpWithEntryData:(id)data{
    NSAssert(data, @"data should be none nill");
    NSAssert([data isKindOfClass:[BCChannel class]], @"data class should be BCChannel");
    self.channel = (BCChannel *)data;
    self.senderId = self.chatManager.bcUser.identity;
    self.senderDisplayName = self.chatManager.bcUser.displayName;
    [self.navigationItem setTitle:self.senderDisplayName];
    [self setUpSignals];
}

#pragma mark - Helper

-(JSQMessagesBubbleImage *)setupOutgoingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:24.0/255.0 green:169.0/255.0 blue:91.0/255.0 alpha:0.75]];
}

-(JSQMessagesBubbleImage *)setupIncomingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}


-(JSQMessage *)convertFromBCMessageToJSQMessageData:(BCMessage *)bcMessage{
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:bcMessage.author.identity
                                                senderDisplayName:bcMessage.author.displayName
                                                             date:bcMessage.createdDate
                                                             text:bcMessage.body];
    return jsqMessage;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
