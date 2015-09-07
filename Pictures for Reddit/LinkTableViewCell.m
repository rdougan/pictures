//
//  LinkTableViewCell.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 05/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "LinkTableViewCell.h"

#import <DTCoreText/NSAttributedString+HTML.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"

@interface LinkTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *thumbnailLoadingIndicator;

@end

@implementation LinkTableViewCell

- (void)awakeFromNib
{
    self.thumbnailImageView.layer.cornerRadius = 4.0f;
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)configureForLink:(RKLink *)link
{
    [self.thumbnailLoadingIndicator startAnimating];
    
    [self.thumbnailImageView sd_setImageWithURL:link.thumbnailURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.thumbnailLoadingIndicator stopAnimating];
    }];
    
    self.titleLabel.text = link.title;
    
    NSString *commentsText = @"comments";
    if (link.totalComments == 1) {
        commentsText = @"comment";
    }
    
    NSString *scoreText = @"points";
    if (link.score == 1) {
        scoreText = @"point";
    }
    
    self.detailsLabel.text = [NSString stringWithFormat:@"%zd %@ • %zd %@\n%@ • by %@", link.score, scoreText, link.totalComments, commentsText, [link.created dateTimeAgo], link.author];
    
    [self updateConstraintsIfNeeded];
}

@end
