//
//  BCChannelViewController.m
//  
//
//  Created by LAL on 2017/6/11.
//
//

#import <Photos/Photos.h>
#import "BCChannelViewController.h"
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessage.h>
#import <UIColor+JSQMessages.h>
#import <JSQSystemSoundPlayer.h>
#import <JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQPhotoMediaItem.h>

@interface BCChannelViewController ()<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
@property(nonatomic, strong) NSString *imageURLNotSetKey;
@property(nonatomic, strong) NSMutableDictionary *PhotoMessageMap;
@property(nonatomic, assign) FIRDatabaseHandle updatdMessageRefHandle;

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

-(void)didPressAccessoryButton:(UIButton *)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
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
    return _storageImageRef;
}

-(NSString *)imageURLNotSetKey{
    if(!_imageURLNotSetKey){
        _imageURLNotSetKey = @"NOTSET";
    }
    return _imageURLNotSetKey;
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

#pragma mark - UITextViewDelegate

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

#pragma mark - UIImagePickerControllerDelegate, UINavigationControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *photoReferenceURL = info[UIImagePickerControllerReferenceURL];
    
    if(photoReferenceURL){
        PHFetchResult *assests = [PHAsset fetchAssetsWithALAssetURLs:@[photoReferenceURL] options:nil];
        PHAsset *asset = [assests firstObject];
        
        NSDictionary *keyPair = [self sendPhotoMessage];
        NSString *fromKey = keyPair[@"fromKey"];
        NSString *toKey = keyPair[@"toKey"];
        
        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            NSURL *imageFileURL = contentEditingInput.fullSizeImageURL;
            NSString *path = [NSString stringWithFormat:@"%@",self.channel.validKey];
            
            NSString *timeIntervalKey = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]*1000];
            
            FIRStorageReference *destRef = [self.storageImageRef child:path];
            NSLog(@"timeinterval key: %@",timeIntervalKey);
            
            [[destRef child:timeIntervalKey] putFile:imageFileURL metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                if(!error){
                    [self setUploadFinishedImageURL:[self.storageImageRef child:metadata.path].description forPhotoMessageWithKey:fromKey forUser:self.chatManager.bcUser];
                    
                    [self setUploadFinishedImageURL:[self.storageImageRef child:metadata.path].description forPhotoMessageWithKey:toKey forUser:[self.channel otherOf:self.chatManager.bcUser]];
                    
                }else{
                    NSLog(@"Error uploading photo: %@",error.localizedDescription);
                }
            }];
        }];
    }else{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSDictionary *keyPair = [self sendPhotoMessage];
        NSString *fromKey = keyPair[@"fromKey"];
        NSString *toKey = keyPair[@"toKey"];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString *path = [NSString stringWithFormat:@"%@",self.channel.validKey];
        FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
        metadata.contentType = @"imag/jpeg";
        [[self.storageImageRef child:path] putData:imageData metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(!error){
                [self setUploadFinishedImageURL:[self.storageImageRef child:metadata.path].description forPhotoMessageWithKey:fromKey forUser:self.chatManager.bcUser];
                
                [self setUploadFinishedImageURL:[self.storageImageRef child:metadata.path].description forPhotoMessageWithKey:toKey forUser:[self.channel otherOf:self.chatManager.bcUser]];
            }else{
                NSLog(@"Error uploading photo: %@",error.localizedDescription);
            }
        }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RACSignal

-(RACSignal *)createMessagesSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.messagesRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *messages = [[BCMessage convertedToTextAndPhotoMessagesFromJSONs:snapshot] mutableCopy];
            for (BCMessage *message in messages){
                if(message.mediaItemKey){
                    message.mediaItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:[message.author isEqual:self.chatManager.bcUser]];
                    if([message.mediaItemKey hasPrefix:@"gs://"]){
                        [self fetchImageDataAtURL:message.mediaItemKey forMediaItem:message.mediaItem clearsPhotoMessgeMapOnSuccessForKey:nil];
                    }
                }
            }
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
    JSQMessage *jsqMessage;
    if(!bcMessage.mediaItemKey){
        jsqMessage = [[JSQMessage alloc] initWithSenderId:bcMessage.author.identity
                                                senderDisplayName:bcMessage.author.displayName
                                                             date:bcMessage.createdDate
                                                             text:bcMessage.body];
    }else{
        jsqMessage = [[JSQMessage alloc] initWithSenderId:bcMessage.author.identity senderDisplayName:bcMessage.author.displayName date:bcMessage.createdDate media:bcMessage.mediaItem];
    }
    return jsqMessage;

}

-(void)leftBarBTNPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)appWillResignActive{
    [self.selfTypingRef setValue:@(NO)];
}

-(NSDictionary *)sendPhotoMessage{
    
    BCMessage *photoMessage = [[BCMessage alloc] initWithAuthor:self.chatManager.bcUser channelKey:self.channel.validKey mediatItemKey:self.imageURLNotSetKey createdTimeStamp:0];
    
    FIRDatabaseReference *photoMessageFromRef = [self.messagesRef childByAutoId];
    [photoMessageFromRef setValue:[photoMessage photoJson]];
    FIRDatabaseReference *photoMessageToRef = [BCRef.root.section(BCRefMessagesSection).user([self.channel otherOf:self.chatManager.bcUser]).child(self.channel.validKey).section(BCRefMessagesSection) childByAutoId];
    [photoMessageToRef setValue:[photoMessage photoJson]];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    return @{@"fromKey":photoMessageFromRef.key,
             @"toKey":photoMessageToRef.key};
}

-(void)setUploadFinishedImageURL:(NSString *)url forPhotoMessageWithKey:(NSString *)key forUser:(BCUser *)user{
    
    FIRDatabaseReference *photoMessageRef = [BCRef.root.section(BCRefMessagesSection).user(user).child(self.channel.validKey).section(BCRefMessagesSection) child:key];
    [photoMessageRef updateChildValues:@{@"mediaItemKey":url}];
}

-(void)addPhotoMessgeWithID:(NSString *)ID key:(NSString *)key mediaItem:(JSQPhotoMediaItem *)mediaItem{
    BCMessage *message = [[BCMessage alloc] initWithAuthor:self.chatManager.bcUser channelKey:self.channel.validKey mediatItem:mediaItem];
    
    [self.messages addObject:message];
    if(mediaItem.image == nil){
        self.PhotoMessageMap[key] = mediaItem;
    }
    [self.collectionView reloadData];
}

-(void)fetchImageDataAtURL:(NSString *)url
              forMediaItem:(JSQPhotoMediaItem *)mediaItem
clearsPhotoMessgeMapOnSuccessForKey:(NSString *)key{
    FIRStorageReference *ref = [[FIRStorage storage] referenceForURL:url];
    [ref dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error downloading image data: %@",error.description);
            return;
        }
        
        [ref metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error){
                NSLog(@"Error downloading metadata: %@",error.description);
            }
            
            if([metadata.contentType isEqualToString: @"image/gif"]){
                mediaItem.image = [UIImage imageWithData:data];
            }else{
                mediaItem.image = [UIImage imageWithData:data];
            }
            [self.collectionView reloadData];
            
            if(!key)return;
            [self.PhotoMessageMap removeObjectForKey:key];
        }];
        
    }];
}

@end
