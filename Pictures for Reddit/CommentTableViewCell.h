//
//  CommentTableViewCell.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RedditKit/RedditKit.h>
#import <DTCoreText/DTCoreText.h>

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) BOOL collapsed;

@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;
@property (nonatomic, weak) IBOutlet UIImageView *expandCollapseView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraint;

- (void)configureForComment:(RKComment *)comment level:(NSInteger)level;

@end
