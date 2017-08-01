//
//  BCSignUpViewController.m
//  BeachChat
//
//  Created by LAL on 2017/6/21.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCSignUpViewController.h"

@interface BCSignUpViewController ()

@end

@implementation BCSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.displayNameIconView.image = [[UIImage imageNamed:@"Nickname"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.displayNameIconView.tintColor = [UIColor grayColor];
    self.displayNameTextField.attributedPlaceholder = self.placeholderNickname;
    self.displayNameTextField.borderStyle = UITextBorderStyleNone;
    self.displayNameTextField.delegate = self;
    self.displayNameView.backgroundColor = [UIColor clearColor];
    self.displayNameIconView.backgroundColor = [UIColor clearColor];
    self.displayNameTextField.backgroundColor = [UIColor clearColor];
    self.diplayNameSeparator.backgroundColor = [UIColor grayColor];
    
    self.signUpBTN.layer.cornerRadius = 5;
    self.signUpBTN.layer.borderColor = [UIColor whiteColor].CGColor;
    self.signUpBTN.layer.borderWidth = 1;
    self.signUpBTN.layer.cornerRadius = 5;
    self.signUpBTN.backgroundColor = [UIColor colorWithRed:72/255.0 green:204/255.0 blue:186/255.0 alpha:1.0];
    
    self.signInBTN.titleLabel.textColor = [UIColor colorWithRed:72/255.0 green:204/255.0 blue:186/255.0 alpha:1.0];

    self.signInBTN.layer.borderColor = [UIColor clearColor].CGColor;
    self.signInBTN.layer.borderWidth = 0;
    self.signInBTN.layer.cornerRadius = 0;
    self.signUpLabel.text = @"Already have an account?";

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    [self.logView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.logView.superview.mas_centerX);
        make.centerY.equalTo(self.logView.superview.mas_centerY).multipliedBy(1.2);
        make.width.equalTo(self.logView.superview.mas_width).multipliedBy(0.6);
        make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.325);
    }];
    
    //userNameView
    [self.usernameView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.usernameView.superview.mas_centerX);
        make.top.equalTo(self.usernameView.superview.mas_top);
        make.width.equalTo(self.usernameView.superview.mas_width);
        make.height.equalTo(self.usernameView.superview.mas_height).multipliedBy(0.2/1.3);
    }];
    
    //displayNameView
    [self.displayNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.displayNameView.superview.mas_centerX);
        make.centerY.equalTo(self.displayNameView.superview.mas_centerY).multipliedBy(0.8/1.3);
        make.width.equalTo(self.displayNameView.superview.mas_width);
        make.height.equalTo(self.displayNameView.superview.mas_height).multipliedBy(0.2/1.3);
    }];
    
    
    [self.displayNameIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.displayNameIconView.superview.mas_centerY);
        make.height.equalTo(self.displayNameIconView.superview.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.displayNameIconView.mas_height);
        make.leftMargin.equalTo(@0);
    }];
    
    [self.displayNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.displayNameTextField.superview.mas_top);
        make.right.equalTo(self.displayNameTextField.superview.mas_right);
        make.left.equalTo(self.displayNameIconView.mas_right).with.offset(10);
        make.height.equalTo(self.displayNameTextField.superview.mas_height);
    }];
    
    [self.diplayNameSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.diplayNameSeparator.superview.mas_left).offset(0);
        make.right.equalTo(self.diplayNameSeparator.superview.mas_right);
        make.bottom.equalTo(self.diplayNameSeparator.superview.mas_bottom);
        make.height.equalTo(@(1));
    }];
    
    //passwordView
    [self.passwordView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.passwordView.superview.mas_centerX);
        make.centerY.equalTo(self.passwordView.superview.mas_centerY).multipliedBy(1.4/1.3);
        make.width.equalTo(self.passwordView.superview.mas_width);
        make.height.equalTo(self.passwordView.superview.mas_height).multipliedBy(0.2/1.3);
    }];
    
    //signUpBTN

    [self.signUpBTN mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.signUpBTN.superview.mas_left);
        make.centerY.equalTo(self.signUpBTN.superview.mas_centerY).multipliedBy(2/1.3);
        make.width.equalTo(self.signUpBTN.superview.mas_width).multipliedBy(1);
        make.height.equalTo(self.signUpBTN.superview.mas_height).multipliedBy(0.2/1.3);
    }];
    
    //signInView
    [self.signUpView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signUpView.superview.mas_right);
        make.bottom.equalTo(self.signUpView.superview.mas_bottom);
        make.width.equalTo(self.signUpView.superview.mas_width).multipliedBy(1);
        make.height.equalTo(self.signUpView.superview. mas_height).multipliedBy(0.15/1.3);
    }];
    
    [self.signInBTN mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signInBTN.superview.mas_right);
        make.bottom.equalTo(self.signInBTN.superview.mas_bottom);
        make.width.equalTo(self.signInBTN.superview.mas_width).multipliedBy(0.3);
        make.height.equalTo(self.signInBTN.superview.mas_height).multipliedBy(1);
    }];
    
    [self.signUpLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signInBTN.mas_left).with.offset(0);
        make.bottom.equalTo(self.signUpLabel.superview.mas_bottom);
        make.left.equalTo(self.signUpLabel.superview.mas_left);
        make.height.equalTo(self.signUpLabel.superview. mas_height).multipliedBy(1);
    }];

}

- (IBAction)signUpBTNPressed:(id)sender {
    NSLog(@"signUp!!!");
}

- (IBAction)signInBTNPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSAttributedString *)placeholderNickname{
    if(!_placeholderNickname){
        _placeholderNickname = [[NSAttributedString alloc] initWithString:@"Nickname" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
    }
    return _placeholderNickname;
}

- (void)keyboardWillShow:(NSNotification *)notification{
    if(!self.isKeyboardShowed){
        self.isKeyboardShowed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                [self.logView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.logView.superview.mas_centerX);
                    make.centerY.equalTo(self.logView.superview.mas_centerY).multipliedBy(0.8);
                    make.width.equalTo(self.logView.superview.mas_width).multipliedBy(0.6);
                    make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.325);
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
                    make.height.equalTo(self.logView.superview.mas_height).multipliedBy(0.325);
                }];
                [self.view layoutIfNeeded];
            }];
        });
    }
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.text.length == 0 || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length == 0){
        [textField setText:@""];
        if([textField isEqual: self.emailTextField]){
            textField.attributedPlaceholder = self.placeholderEmail;
        }else if([textField isEqual:self.passwordTextField]){
            textField.attributedPlaceholder = self.placeholderPIN;
        }else if([textField isEqual:self.displayNameTextField]){
            textField.attributedPlaceholder = self.placeholderNickname;
        }
    }
    [textField resignFirstResponder];
}

-(void)tapViewToDismissKeyboard:(UIGestureRecognizer *)recognizer{
    [super tapViewToDismissKeyboard:recognizer];
    [self textFieldShouldReturn:self.displayNameTextField];
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
