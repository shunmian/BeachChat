//
//  BCChannelUnreadMessageNotificationView.m
//  BeachChat
//
//  Created by LAL on 2017/6/19.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "BCChannelUnreadMessageNotificationView.h"

@implementation BCChannelUnreadMessageNotificationView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [bezierPath addArcWithCenter:center radius:self.bounds.size.width/2-1 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bezierPath setLineWidth:0.5];
    [[UIColor redColor] setFill];
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    [bezierPath fill];
}


@end
