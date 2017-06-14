//
//  BCChannelTableViewCell.m
//  BeachChat
//
//  Created by LAL on 2017/6/14.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChannelTableViewCell.h"

const CGFloat OFFSET = 5;

@implementation BCChannelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setUp];
    }
    return self;
}

-(void)setUp{


}

-(void)updateConstraints{
    [super updateConstraints];
    
    [self.avartarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(OFFSET));
        make.left.equalTo(@(OFFSET));
        make.bottom.equalTo(@(-OFFSET));
        make.width.equalTo(self.avartarView.mas_height);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(OFFSET));
        make.left.equalTo(@(OFFSET));
        make.height.equalTo(self.contentView.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.contentView.mas_width).multipliedBy(0.5);
    }];
    
    [self.updatedDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(OFFSET));
        make.right.equalTo(@(-OFFSET));
        make.width.equalTo(self.contentView.mas_width).multipliedBy(0.25);
        make.bottom.equalTo(@(-OFFSET));
    }];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
