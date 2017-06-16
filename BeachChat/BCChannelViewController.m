//
//  BCChannelViewController.m
//  
//
//  Created by LAL on 2017/6/11.
//
//

#import <Photos/Photos.h>
#import "BCChannelViewController.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessage.h"
#import "UIColor+JSQMessages.h"
#import "JSQSystemSoundPlayer.h"
#import "JSQSystemSoundPlayer+JSQMessages.h"


@interface BCChannelViewController ()<UITextViewDelegate>

//Static Entry Data
@property(nonatomic, strong) BCChannel *channel;

//Shared Manager
@property(nonatomic, strong) BCChatManager *chatManager;

//Messages
@property(nonatomic, strong) NSMutableArray <BCMessage *>* messages;
@property(nonatomic, strong) FIRDatabaseReference *messagesRef;
@property(nonatomic, strong) RACSignal *messagesSignal;

@property(nonatomic, assign) BOOL isOtherTyping;
@property(nonatomic, strong) FIRDatabaseReference *selfTypingRef;
@property(nonatomic, strong) FIRDatabaseReference *otherTypingRef;
@property(nonatomic, strong) RACSignal *otherTypingSignal;

//Images
@property(nonatomic, strong) FIRStorageReference *storageImageRef;


//Views
@property(nonatomic, strong) JSQMessagesBubbleImage *outgointBubbleImageView;
@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;
@property(nonatomic, weak) UITextView *inputTextView;

@end

@implementation BCChannelViewController

#pragma mark - 0_Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Chat" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBTNPressed)];
    self.navigationItem.title = [self.channel otherOf:self.chatManager.bcUser].displayName;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        [self.chatManager createMessage:message inChannel:self.channel withCompletion:^(BCMessage *message, NSError *error) {
            if(!error){
                NSLog(@"message sent successfully:%@",message);
            }else{
                NSLog(@"message sent failed:%@",error);
            }
        }];
        
        self.inputTextView.text= @"";
        [self finishSendingMessage];
        [self scrollToBottomAnimated:YES];
        [JSQSystemSoundPlayer jsq_playMessageSentSound];

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

-(FIRDatabaseReference *)messagesRef{
    if(!_messagesRef){
        _messagesRef = self.chatManager.messagesRef.child(self.channel.validKey).section(BCRefMessagesSection);
    }
    return _messagesRef;
}

-(FIRDatabaseReference *)selfTypingRef{
    if(!_selfTypingRef){
        _selfTypingRef = self.chatManager.messagesRef.child(self.channel.validKey).child(@"isTyping");
    }
    return _selfTypingRef;
}

-(FIRDatabaseReference *)otherTypingRef{
    if(!_otherTypingRef){
        _otherTypingRef = BCRef.root.section(BCRefMessagesSection).user([self.channel otherOf:self.chatManager.bcUser]).child(self.channel.validKey).child(@"isTyping");
    }
    return _otherTypingRef;
}

-(FIRStorageReference *)storageImageRef{
    if(!_storageImageRef){
        _storageImageRef = BCRef.storage;
    }

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

#pragma mark - UITextView Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.selfTypingRef setValue:@(YES)];
    [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.selfTypingRef setValue:@(NO)];
    }];
}

-(void)textViewDidChange:(UITextView *)textView{
    [super textViewDidChange:textView];
    [self.selfTypingRef setValue:@(YES)];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.selfTypingRef setValue:@(NO)];
}

#pragma mark - RACSignal

-(RACSignal *)createMessagesSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.messagesRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *messages = [[BCMessage convertedToMessagesFromJSONs:snapshot] mutableCopy];
            [subscriber sendNext:messages];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(RACSignal *)createOtherTypingSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.otherTypingRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSNumber *isTyping;
            if([snapshot.value isEqual:[NSNull class]]){
                isTyping = @(NO);
            }
            isTyping = snapshot.value;
            [subscriber sendNext:isTyping];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%@ disposed",NSStringFromSelector(_cmd));
        }];
    }];
}

-(void)setUpSignals{
    self.messagesSignal = [self createMessagesSignal];
    [self.messagesSignal subscribeNext:^(NSMutableArray *messages) {
        self.messages = messages;
        [self.collectionView reloadData];
    }];
    self.otherTypingSignal = [self createOtherTypingSignal];
    [self.otherTypingSignal subscribeNext:^(NSNumber *x) {
        if(x.boolValue == YES){
            self.navigationItem.title = @"Friend is typing...";
        }else{
            self.navigationItem.title = [self.channel otherOf:self.chatManager.bcUser].displayName;
        }
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

-(void)leftBarBTNPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)appWillResignActive{
    [self.selfTypingRef setValue:@(NO)];
}

@end
