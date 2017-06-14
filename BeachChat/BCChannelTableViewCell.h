//
//  BCChannelTableViewCell.h
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCChannelTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avartarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDateLabel;

@end
