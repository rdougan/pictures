//
//  SubredditImageViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>
@import GoogleMobileAds;

#import "SubredditSwipeViewController.h"

@class SubredditImageViewController;

@protocol SubredditImageViewControllerDelegate <NSObject>

@required
- (void)subredditImageViewControllerWillHideToolbars:(SubredditImageViewController *)viewController;
- (void)subredditImageViewControllerWillShowToolbars:(SubredditImageViewController *)viewController;

@end

@interface SubredditImageViewController : UIViewController <UIScrollViewDelegate, GADBannerViewDelegate>

@property (nonatomic, weak) id <SubredditImageViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) RKLink *link;

@property (nonatomic, strong) SubredditSwipeViewController *pageViewController;

@property (nonatomic, assign) BOOL showingBanner;

@end
