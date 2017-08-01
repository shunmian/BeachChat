//
//  BCSignUpViewController.h
//  BeachChat
//
//  Created by LAL on 2017/6/21.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCLoginViewController.h"

@interface BCSignUpViewController : BCLoginViewController
@property (weak, nonatomic) IBOutlet UIView *usernameSeparator;
@property (weak, nonatomic) IBOutlet UIView *diplayNameSeparator;
@property (weak, nonatomic) IBOutlet UIView *passwordSeparator;

@property (weak, nonatomic) IBOutlet UIView *displayNameView;
@property (weak, nonatomic) IBOutlet UIImageView *displayNameIconView;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (nonatomic, strong) NSAttributedString *placeholderNickname;
@end
