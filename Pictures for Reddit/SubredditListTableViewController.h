//
//  SubredditListTableViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>

#import "SubredditSwipeViewController.h"

@interface SubredditListTableViewController : UITableViewController <SubredditSwipeViewControllerDelegate>

@property (nonatomic, strong) RKSubreddit *subreddit;

@end
