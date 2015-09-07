//
//  Helper.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 05/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RedditKit/RedditKit.h>

@interface Helper : NSObject

+ (instancetype)sharedClient;

+ (NSAttributedString *)attributedTitleForSubreddit:(RKSubreddit *)subreddit;

@end
