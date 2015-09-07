//
//  Helper.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 05/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "Helper.h"

#import <DTCoreText/DTCoreText.h>

@implementation Helper

+ (instancetype)sharedClient
{
    static Helper *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[Helper alloc] init];
    });
    
    return sharedInstance;
}

+ (NSAttributedString *)attributedTitleForSubreddit:(RKSubreddit *)subreddit
{
    if (subreddit == nil) {
        return nil;
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:@"/r/" attributes:@{
                                                                                                 NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                                 NSFontAttributeName: [UIFont systemFontOfSize:17.0f]
                                                                                                 }]];
    
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:subreddit.name attributes:@{
                                                                                                         NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                                         NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]
                                                                                                         }]];
    
    return title;
}

@end
