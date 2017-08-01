//
//  BCChannelTableViewCell.m
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChannelTableViewCell.h"

const CGFloat OFFSET = 10;

@implementation BCChannelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setUp];
}

//-(instancetype)initWithCoder:(NSCoder *)aDecoder{
//    if(self = [super initWithCoder:aDecoder]){
//        [self setUp];
//    }
//    return self;
//}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setUp];
    }
    return self;
}

-(void)setUp{
    self.avartarView.layer.cornerRadius = 6;
    self.avartarView.layer.masksToBounds = YES;
    self.unreadMessageNotificationView.hidden = YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.avartarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avartarView.superview.mas_top).with.offset(OFFSET);
        make.left.equalTo(self.avartarView.superview.mas_left).with.offset(OFFSET);
        make.bottom.equalTo(self.avartarView.superview.mas_bottom).with.offset(-OFFSET);
        make.width.equalTo(self.avartarView.mas_height);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.superview.mas_top).with.offset(OFFSET);
        make.left.equalTo(self.avartarView.mas_right).with.offset(OFFSET);
//        make.height.equalTo(self.nameLabel.superview.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.nameLabel.superview.mas_width).multipliedBy(0.5);
    }];
    
    [self.lastMessageBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(OFFSET/2);
        make.left.equalTo(self.avartarView.mas_right).with.offset(OFFSET);
        make.bottom.equalTo(self.lastMessageBodyLabel.superview.mas_bottom).with.offset(-OFFSET);
        make.right.equalTo(self.updatedDateLabel.superview.mas_right).with.offset(-OFFSET);
    }];
    
    [self.updatedDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updatedDateLabel.superview.mas_top).with.offset(OFFSET*1.5);
        make.right.equalTo(self.updatedDateLabel.superview.mas_right).with.offset(-OFFSET);
//        make.height.equalTo(self.updatedDateLabel.superview.mas_height).multipliedBy(0.4);
        make.width.equalTo(self.updatedDateLabel.superview.mas_width).multipliedBy(0.25);
    }];

    [self.unreadMessageNotificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avartarView.mas_right).with.offset(-2);
        make.centerY.equalTo(self.avartarView.mas_top).with.offset(2);
        make.width.equalTo(@(10));
        make.height.equalTo(@(10));
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
