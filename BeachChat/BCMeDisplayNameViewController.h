//
//  BCMeDisplayNameViewController.h
//  BeachChat
//
//  Created by LAL on 2017/6/18.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCMeDisplayNameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
-(void)setUpWithEntryData:(id)data;
@end
