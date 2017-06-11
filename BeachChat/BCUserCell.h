//
//  BCUserCell.h
//  BeachChat
//
//  Created by LAL on 2017/6/8.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCFriendRequest.h"


@class BCUserCell;
@protocol BCUserDelegate
-(void)sendFriendRequest:(BCFriendRequest *)friendRequest;
@end

@protocol BCUserDataSource <NSObject>
-(BCFriendRequest *)friendRequestForTableViewCell:(BCUserCell *)cell;
@end

@interface BCUserCell : UITableViewCell
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id dataSource;
@property (weak, nonatomic) IBOutlet UIButton *friendRequestBTN;
@property (nonatomic, assign) NSIndexPath *indexpath;
@end
