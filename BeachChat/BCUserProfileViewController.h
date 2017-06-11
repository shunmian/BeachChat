//
//  BCUserProfileViewController.h
//  BeachChat
//
//  Created by LAL on 2017/6/9.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCUserProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (nonatomic, strong) BCUser *user;
-(void)setUpWithEntryData:(id)data;
@end
