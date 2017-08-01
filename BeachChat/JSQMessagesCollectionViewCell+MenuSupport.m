//
//  JSQMessagesCollectionViewCell+MenuSupport.m
//  BeachChat
//
//  Created by LAL on 2017/6/17.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "JSQMessagesCollectionViewCell+MenuSupport.h"

@implementation JSQMessagesCollectionViewCell (MenuSupport)
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action == @selector(copy:) || action == @selector(forward:) || action == @selector(delete:)){
        return YES;
    }else{
        return NO;
    }
}

-(void) delete:(id)sender{
    JSQMessagesCollectionView* collecitonView=(JSQMessagesCollectionView*)[self superview];
    if ([collecitonView isKindOfClass:[JSQMessagesCollectionView class]]) {
        id <UICollectionViewDelegate> d=collecitonView.delegate;
        if  ([d respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]){
            [d collectionView:collecitonView performAction:@selector(delete:) forItemAtIndexPath:[collecitonView indexPathForCell:self] withSender:sender];
        }
    }
}

-(void) forward:(id)sender{
    JSQMessagesCollectionView* collecitonView=(JSQMessagesCollectionView*)[self superview];
    if ([collecitonView isKindOfClass:[JSQMessagesCollectionView class]]) {
        id <UICollectionViewDelegate> d=collecitonView.delegate;
        if  ([d respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]){
            [d collectionView:collecitonView performAction:@selector(forward:) forItemAtIndexPath:[collecitonView indexPathForCell:self] withSender:sender];
        }
    }
}


-(void) copy:(id)sender{
    JSQMessagesCollectionView* collecitonView=(JSQMessagesCollectionView*)[self superview];
    if ([collecitonView isKindOfClass:[JSQMessagesCollectionView class]]) {
        id <UICollectionViewDelegate> d=collecitonView.delegate;
        if  ([d respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]){
            [d collectionView:collecitonView performAction:@selector(copy:) forItemAtIndexPath:[collecitonView indexPathForCell:self] withSender:sender];
        }
    }
}
@end
