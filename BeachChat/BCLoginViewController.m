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
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation BCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"server time: %@",[FIRServerValue timestamp]);
//    );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUpBTNPressed:(id)sender {
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            NSLog(@"user create successful: %@",user);
            user.identity = self.emailTextField.text;
            [[BCChatManager sharedManager] setUpWithEntryData:user];
            [[BCChatManager sharedManager] createUser:[BCChatManager sharedManager].bcUser];
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
            [[BCChatManager sharedManager] setFirUser:user];
            user.identity = self.emailTextField.text;
            [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
        }else{
            NSLog(@"user sign in failed:%@",[error localizedDescription]);
        }
    }];
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
