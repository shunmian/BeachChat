//
//  BCLoginViewController.m
//  
//
//  Created by LAL on 2017/6/7.
//
//

#import "BCLoginViewController.h"
#import "BCChatManager.h"
#import "FIRUser+User.h"


@interface BCLoginViewController ()

@end

const CGFloat kBCLoginViewOffset = 10;


@implementation BCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"Background1"].CGImage);
    
    self.appTitleLabel.text = @"D O D O";
    self.appTitleLabel.textColor = [UIColor whiteColor];
    self.usernameIconView.image = [[UIImage imageNamed:@"Email"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.usernameIconView.tintColor = [UIColor grayColor];
    self.usernameView.backgroundColor = [UIColor clearColor];
    self.usernameSeparator.backgroundColor = [UIColor grayColor];
    
    
    self.emailTextField.backgroundColor = [UIColor clearColor];
    self.passwordView.backgroundColor = [UIColor clearColor];
    self.passwordTextField.backgroundColor = [UIColor clearColor];
    self.passwordIconView.image = [[UIImage imageNamed:@"PIN"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.passwordIconView.tintColor = [UIColor grayColor];
    self.passwordSeparator.backgroundColor = [UIColor grayColor];
    
    
    
    self.signUpLabel.text = @"Don't have an account?";
    self.signUpLabel.textAlignment = NSTextAlignmentRight;
    self.signUpBTN.backgroundColor = [UIColor clearColor];
    self.signUpBTN.tintColor = [UIColor redColor];
    self.signUpView.backgroundColor = [UIColor clearColor];

    self.emailTextField.attributedPlaceholder = self.placeholderEmail;
    self.emailTextField.borderStyle = UITextBorderStyleNone;
    self.emailTextField.delegate = self;
    
    self.passwordTextField.attributedPlaceholder = self.placeholderPIN;
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.delegate = self;
    
    self.signInBTN.layer.cornerRadius = 5;
    self.signInBTN.layer.borderColor = [UIColor whiteColor].CGColor;
    self.signInBTN.layer.borderWidth = 1;
    self.signUpBTN.layer.cornerRadius = 5;
    
    //tap Gesture Recognizer
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewToDismissKeyboard:)];
    [self.view addGestureRecognizer:tapGR];
    tapGR.delegate = self;
    self.signInBTN.backgroundColor = [UIColor clearColor];
    self.signInBTN.layer.borderColor = [UIColor whiteColor].CGColor;

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.logViewMovingDeltaY = self.view.frame.size.height/8;
    self.logViewOriginalFrame = self.logView.frame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.appTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.appTitleLabel.superview.mas_centerX);
        make.centerY.equalTo(self.appTitleLabel.superview.mas_centerY).multipliedBy(0.3);
        make.width.equalTo(self.appTitleLabel.superview.mas_width).multipliedBy(0.6);
    }];
    
    [self.logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.logView.superview.mas_centerX);
        make.centerY.equalTo(self.logView.superview.mas_centerY).multipliedBy(1.2);
        make.width.equalTo(self.logView.superview.mas_width).multipliedBy(0.6);
        make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.25);
    }];
    
    //usernameView
    [self.usernameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.usernameView.superview.mas_centerX);
        make.top.equalTo(self.usernameView.superview.mas_top);
        make.width.equalTo(self.usernameView.superview.mas_width);
        make.height.equalTo(self.usernameView.superview.mas_height).multipliedBy(0.2);
    }];
    
    [self.usernameIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.usernameIconView.superview.mas_centerY);
        make.height.equalTo(self.usernameIconView.superview.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.usernameIconView.mas_height);
        make.leftMargin.equalTo(@0);
    }];
    
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.superview.mas_top);
        make.right.equalTo(self.emailTextField.superview.mas_right);
        make.left.equalTo(self.usernameIconView.mas_right).with.offset(10);
        make.height.equalTo(self.emailTextField.superview.mas_height);
    }];
    
    [self.usernameSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.usernameSeparator.superview.mas_left).offset(0);
        make.right.equalTo(self.usernameSeparator.superview.mas_right);
        make.bottom.equalTo(self.usernameSeparator.superview.mas_bottom);
        make.height.equalTo(@(1));
    }];
    
    
    
    //passwordView
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.passwordView.superview.mas_centerX);
        make.centerY.equalTo(self.passwordView.superview.mas_centerY).multipliedBy(0.8);
        make.width.equalTo(self.passwordView.superview.mas_width);
        make.height.equalTo(self.passwordView.superview.mas_height).multipliedBy(0.2);
    }];

    
    [self.passwordIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.passwordIconView.superview.mas_centerY);
        make.height.equalTo(self.passwordIconView.superview.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.passwordIconView.mas_height);
        make.leftMargin.equalTo(@0);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.superview.mas_top);
        make.right.equalTo(self.passwordTextField.superview.mas_right);
        make.left.equalTo(self.usernameIconView.mas_right).with.offset(10);
        make.height.equalTo(self.passwordTextField.superview.mas_height);
    }];
    
    [self.passwordSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passwordSeparator.superview.mas_left).offset(0);
        make.right.equalTo(self.passwordSeparator.superview.mas_right);
        make.bottom.equalTo(self.passwordSeparator.superview.mas_bottom);
        make.height.equalTo(@(1));
    }];
    
    
    //BTN
    [self.signInBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.signInBTN.superview.mas_left);
        make.centerY.equalTo(self.signInBTN.superview.mas_centerY).multipliedBy(1.4);
        make.width.equalTo(self.signInBTN.superview.mas_width).multipliedBy(1);
        make.height.equalTo(self.signInBTN.superview.mas_height).multipliedBy(0.2);
    }];
    
    [self.signUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signUpView.superview.mas_right);
        make.bottom.equalTo(self.signUpView.superview.mas_bottom);
        make.width.equalTo(self.signUpView.superview.mas_width).multipliedBy(1);
        make.height.equalTo(self.signUpView.superview. mas_height).multipliedBy(0.15);
    }];
    
    
    [self.signUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signUpBTN.mas_left).with.offset(0);
        make.bottom.equalTo(self.signUpLabel.superview.mas_bottom);
        make.left.equalTo(self.signUpLabel.superview.mas_left);
        make.height.equalTo(self.signUpLabel.superview. mas_height).multipliedBy(1);
    }];

    [self.signUpBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signUpBTN.superview.mas_right);
        make.bottom.equalTo(self.signUpBTN.superview.mas_bottom);
        make.width.equalTo(self.signUpBTN.superview.mas_width).multipliedBy(0.3);
        make.height.equalTo(self.signUpBTN.superview. mas_height).multipliedBy(1);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUpBTNPressed:(id)sender {
    [self performSegueWithIdentifier:@"toSignUpSegue" sender:self];
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            NSLog(@"user create successful: %@",user);
            user.identity = self.emailTextField.text;
            [[BCChatManager sharedManager] setUpWithEntryData:user isSignIn:NO];
            NSLog(@"before segue");
            [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
            NSLog(@"after segue");
        }else{
            NSLog(@"user create failed: %@",[error localizedDescription]);
        }
    }];
}
- (IBAction)signInBTNPressed:(id)sender {
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            NSLog(@"user sign in successful: %@",user);
            user.identity = self.emailTextField.text;
            [[BCChatManager sharedManager] setUpWithEntryData:user isSignIn:YES];
            
            [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
        }else{
            NSLog(@"user sign in failed:%@",[error localizedDescription]);
        }
    }];
}

#pragma mark - Setter & Getter

-(NSAttributedString *)placeholderEmail{
    if(!_placeholderEmail){
        _placeholderEmail = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
    }
    return _placeholderEmail;
}

-(NSAttributedString *)placeholderPIN{
    if(!_placeholderPIN){
        _placeholderPIN = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
    }
    return _placeholderPIN;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.attributedPlaceholder = nil;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.text.length == 0 || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length == 0){
        [textField setText:@""];
        if([textField isEqual: self.emailTextField]){
            textField.attributedPlaceholder = self.placeholderEmail;
        }else if([textField isEqual:self.passwordTextField]){
            textField.attributedPlaceholder = self.placeholderPIN;
        }
    }
    [textField resignFirstResponder];
}

#pragma mark - helper

- (void)keyboardWillShow:(NSNotification *)notification{
    if(!self.isKeyboardShowed){
        self.isKeyboardShowed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                [self.logView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.logView.superview.mas_centerX);
                    make.centerY.equalTo(self.logView.superview.mas_centerY).multipliedBy(0.8);
                    make.width.equalTo(self.logView.superview.mas_width).multipliedBy(0.6);
                    make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.3);
                }];
                [self.view layoutIfNeeded];
            }];
        });
    }
}

-(void)keyboardWillHide:(NSNotification *)notification{
    if(self.isKeyboardShowed){
        self.isKeyboardShowed = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                [self.logView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.logView.superview.mas_centerX);
                    make.centerY.equalTo(self.logView.superview.mas_centerY).multipliedBy(1.2);
                    make.width.equalTo(self.logView.superview.mas_width).multipliedBy(0.6);
                    make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.3);
                }];
                [self.view layoutIfNeeded];
            }];
        });
    }
}

-(void)tapViewToDismissKeyboard:(UIGestureRecognizer *)recognizer{
    [self textFieldShouldReturn:self.emailTextField];
    [self textFieldShouldReturn:self.passwordTextField];
}

@end
