//
//  CommentsTreeViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>
#import <RATreeView/RATreeView.h>

@class CommentsTreeViewController;

@protocol CommentsTreeViewControllerDelegate <NSObject>

@optional
- (void)commentsTreeViewControllerClose:(CommentsTreeViewController *)viewController;

@end

@interface CommentsTreeViewController : UIViewController <RATreeViewDataSource, RATreeViewDelegate>

@property (nonatomic, weak) id <CommentsTreeViewControllerDelegate> delegate;

@property (nonatomic, strong) RKLink *link;

@end