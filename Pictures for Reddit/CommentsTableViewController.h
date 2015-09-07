//
//  CommentsTableViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>

@class CommentsTableViewController;

@protocol CommentsTableViewControllerDelegate <NSObject>

@optional
- (void)commentsTableViewControllerClose:(CommentsTableViewController *)viewController;

@end

@interface CommentsTableViewController : UITableViewController

@property (nonatomic, weak) id <CommentsTableViewControllerDelegate> delegate;

@property (nonatomic, strong) RKLink *link;

@end