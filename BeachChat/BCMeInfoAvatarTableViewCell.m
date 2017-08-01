//
//  BCMeInfoTableViewCell.m
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCMeInfoAvatarTableViewCell.h"

static NSInteger OFFSET = 15;

@implementation BCMeInfoAvatarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setup];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

-(void)setup{
    self.displayNameLabel.textAlignment = NSTextAlignmentRight;
    self.displayNameLabel.textColor = [UIColor grayColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.displayNameLabel.backgroundColor = [UIColor clearColor];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.superview.mas_top).with.offset(OFFSET);
        make.right.equalTo(self.avatarView.superview.mas_right).with.offset(-OFFSET);
        make.bottom.equalTo(self.avatarView.superview.mas_bottom).with.offset(-OFFSET);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1.0);
    }];
    
    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.itemLabel.superview.mas_top).with.offset(OFFSET);
        make.left.equalTo(self.itemLabel.superview.mas_left).with.offset(OFFSET);
        make.bottom.equalTo(self.itemLabel.superview.mas_bottom).with.offset(-OFFSET);
        make.width.equalTo(self.itemLabel.superview.mas_width).multipliedBy(0.6);
    }];
    
    [self.displayNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.displayNameLabel.superview.mas_top).with.offset(OFFSET);
        make.right.equalTo(self.displayNameLabel.superview.mas_right).with.offset(-OFFSET);
        make.bottom.equalTo(self.displayNameLabel.superview.mas_bottom).with.offset(-OFFSET);
        make.width.equalTo(self.displayNameLabel.superview.mas_width).multipliedBy(0.5);
    }];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
