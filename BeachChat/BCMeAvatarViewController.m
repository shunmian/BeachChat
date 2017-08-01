//
//  BCMeAvatarViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMeAvatarViewController.h"

@interface BCMeAvatarViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic, strong) BCChatManager *chatManager;

@property(nonatomic, strong) FIRDatabaseReference *avatarMessageRef;
@property(nonatomic, strong) RACSignal *avatarURLSignal;
@property(nonatomic, strong) UIActionSheet *avatarActionSheet;
@property(nonatomic, strong) NSString *imageURLNotSetKey;
@end

@implementation BCMeAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Avatar";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStylePlain target:self action:@selector(selectAvatar)];
    self.imageURLNotSetKey = @"NOTSET";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarImageView.superview.mas_centerX);
        make.centerY.equalTo(self.avatarImageView.superview.mas_centerY);
        make.width.equalTo(self.avatarImageView.superview.mas_width);
        make.height.equalTo(self.avatarImageView.superview.mas_width);
    }];
}

#pragma mark - 0 level setter & getter
-(BCChatManager *)chatManager{
    if(!_chatManager){
        _chatManager = [BCChatManager sharedManager];
    }
    return _chatManager;
}

#pragma mark - other setter & getter

-(FIRDatabaseReference *)avatarMessageRef{
    if(!_avatarMessageRef){
        _avatarMessageRef = BCRef.root.section(BCRefUsersSection).user(self.chatManager.bcUser).child(@"avatar").child(@"url");
    }
    return _avatarMessageRef;
}

-(UIActionSheet *)avatarActionSheet{
    if(!_avatarActionSheet){
        _avatarActionSheet = [[UIActionSheet alloc] initWithTitle:@"avatar" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"photo album",@"camera", nil];
        _avatarActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    }
    return _avatarActionSheet;
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self chooseAvatarFromAlbum];
            break;
        case 1:
            [self chooseAvatarFromCamera];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *photoReferenceURL = info[UIImagePickerControllerReferenceURL];

    BCAvatar *avatar = [[BCAvatar alloc] initFromLocalWithUser:self.chatManager.bcUser url:self.imageURLNotSetKey];
    
    if(photoReferenceURL){
        PHFetchResult *assests = [PHAsset fetchAssetsWithALAssetURLs:@[photoReferenceURL] options:nil];
        PHAsset *asset = [assests firstObject];
        [self.chatManager createAvatar:avatar withAsset:asset withCompletion:^(BCAvatar *returnAvatar, NSError *error) {
            if(!error){
                NSLog(@"avatar from photo created success:%@",returnAvatar);
            }
        }];
    }else{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        [self.chatManager createAvatar:avatar withData:imageData withCompletion:^(BCAvatar *returnAvatar, NSError *error) {
            if(!error){
                NSLog(@"avatar from camera created success: %@",returnAvatar);
            }
        }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(RACSignal *)createAvatarURLSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.avatarMessageRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
    self.avatarURLSignal = [self createAvatarURLSignal];
    
    [self.avatarURLSignal subscribeNext:^(NSString *url) {
        if(!url){
            self.avatarImageView.image = [UIImage imageNamed:@"defaultUserAvatar"];
        }else{
            NSLog(@"image url is :%@",url);
            [self.chatManager fetchImageDataAtURL:url withComletion:^(UIImage *image, NSError *error) {
                if(!error){
                    self.avatarImageView.image = image;
                }
            }];
        }
    }];
}

-(void)setUpWithEntryData:(id)data{
    [self setUpSignals];
}

-(void)selectAvatar{
    NSLog(@"select avatar");
    [self.avatarActionSheet showInView:self.view];
}

-(void)chooseAvatarFromAlbum{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)chooseAvatarFromCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

@end
