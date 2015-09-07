//
//  ChooseSubredditTableViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>

@class ChooseSubredditTableViewController;

@protocol ChooseSubredditTableViewControllerDelegate <NSObject>

@required
- (void)chooseSubreddit:(ChooseSubredditTableViewController *)viewController didSelectSubreddit:(RKSubreddit *)subreddit;

@optional
- (void)chooseSubredditDidCancel:(ChooseSubredditTableViewController *)viewController;
- (BOOL)chooseSubreddit:(ChooseSubredditTableViewController *)viewController canAddSubreddit:(RKSubreddit *)subreddit;

@end

@interface ChooseSubredditTableViewController : UITableViewController <UISearchResultsUpdating>

@property (nonatomic, weak) id <ChooseSubredditTableViewControllerDelegate> delegate;

@end
