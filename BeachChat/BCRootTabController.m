//
//  BCRootTabController.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCRootTabController.h"
#import "BCChannelsTableViewController.h"


@interface BCRootTabController ()

@end

@implementation BCRootTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationController *nav = self.viewControllers[0];
    BCChannelsTableViewController *ctvc = nav.viewControllers[0];
    [ctvc setUpWithEntryData:nil];
    self.tabBar.selectedImageTintColor= [UIColor colorWithRed:90/255.0 green:186/255.0 blue:122/255.0 alpha:1];
    self.tabBar.items[0].image = [UIImage imageNamed:@"Chat_Normal"];
    [self.tabBar.items[0] setSelectedImage:[UIImage imageNamed:@"Chat_Selected"]];
    self.tabBar.items[1].image = [UIImage imageNamed:@"Friend_Normal"];
    [self.tabBar.items[1] setSelectedImage:[UIImage imageNamed:@"Friend_Selected"]];
    self.tabBar.items[2].image = [UIImage imageNamed:@"Me_Normal"];
    [self.tabBar.items[2] setSelectedImage:[UIImage imageNamed:@"Me_Selected"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
