//
//  SubredditSwipeViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;
#import <RedditKit/RedditKit.h>

#import "CommentsWebViewController.h"
#import "CommentsTableViewController.h"
#import "CommentsTreeViewController.h"
#import "SubredditSwipeViewController.h"

@protocol SubredditSwipeViewControllerDelegate <NSObject>

@required
- (NSArray *)subredditSwipeViewLinks;
- (void)subredditSwipeViewDidViewLink:(RKLink *)link;

@end

@interface SubredditSwipeViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, CommentsWebViewControllerDelegate, CommentsTableViewControllerDelegate, CommentsTreeViewControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, weak) id <SubredditSwipeViewControllerDelegate> linksDelegate;
@property (nonatomic, assign) BOOL toolbarsHidden;

- (void)setActiveLink:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end
