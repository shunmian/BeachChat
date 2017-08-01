//
//  BCMeInfoTableViewCell.h
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCMeInfoAvatarTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@end
