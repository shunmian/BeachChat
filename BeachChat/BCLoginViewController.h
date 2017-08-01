//
//  BCLoginViewController.h
//  
//
//  Created by LAL on 2017/6/7.
//
//

#import <UIKit/UIKit.h>

@interface BCLoginViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *appTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *logView;
@property (weak, nonatomic) IBOutlet UIImageView *usernameIconView;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIconView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *signUpBTN;
@property (weak, nonatomic) IBOutlet UIButton *signInBTN;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UIView *usernameSeparator;
@property (weak, nonatomic) IBOutlet UIView *passwordSeparator;

//keyboard moving
@property (nonatomic, assign) BOOL isKeyboardShowed;
@property (nonatomic, assign) CGFloat keyboardTopViewHeight;
@property (nonatomic, assign) CGFloat logViewMovingDeltaY;
@property (nonatomic, assign) CGRect logViewOriginalFrame;

//texField placeholder
@property (nonatomic, strong) NSAttributedString *placeholderEmail;
@property (nonatomic, strong) NSAttributedString *placeholderPIN;

-(void)tapViewToDismissKeyboard:(UIGestureRecognizer *)recognizer;
@end
