//
//  BCUserCell.m
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCUserCell.h"

@implementation BCUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addFriendRequestBTNPressed:(id)sender {
    BCFriendRequest *friendRequest = [self.dataSource friendRequestForTableViewCell:self];
    [self.delegate sendFriendRequest: friendRequest];
}

@end
