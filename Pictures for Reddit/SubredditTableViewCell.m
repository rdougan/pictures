//
//  SubredditTableViewCell.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 05/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "SubredditTableViewCell.h"

@interface SubredditTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nsfwLabel;

@end

@implementation SubredditTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}

- (void)configureWithSubreddit:(RKSubreddit *)subreddit
{
    self.titleLabel.text = subreddit.name;
    self.nameLabel.text = [subreddit.URL stringByDeletingPathExtension];
}

@end
