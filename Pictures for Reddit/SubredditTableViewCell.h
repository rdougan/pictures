//
//  SubredditTableViewCell.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 05/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>

@interface SubredditTableViewCell : UITableViewCell

- (void)configureWithSubreddit:(RKSubreddit *)subreddit;

@end
