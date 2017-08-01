//
//  BCMeDisplayNameViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMeDisplayNameViewController.h"

@interface BCMeDisplayNameViewController ()
@property(nonatomic, strong) BCChatManager *chatManager;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) FIRDatabaseReference *displayNameRef;
@end

@implementation BCMeDisplayNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"display Name";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    // Do any additional setup after loading the view.
    self.displayNameTextField.text = self.displayName;
    self.displayNameTextField.clearButtonMode = UITextFieldViewModeAlways;
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

-(FIRDatabaseReference *)displayNameRef{
    if(!_displayNameRef){
        _displayNameRef = BCRef.root.section(BCRefUsersSection).user(self.chatManager.bcUser).child(@"displayName");
    }
    return _displayNameRef;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirm{
    [self.displayNameRef setValue:self.displayNameTextField.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpWithEntryData:(id)data{
    NSParameterAssert([data isKindOfClass:[NSString class]]);
    self.displayName = (NSString *)data;
}

@end
