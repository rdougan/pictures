//
//  CommentTableViewCell.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "CommentTableViewCell.h"

#import "NSDate+TimeAgo.h"
#import "NSString+RKHTML.h"

@implementation CommentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)setLevel:(NSInteger)level
{
    if (level != _level) {
        _level = level;
        
        self.leftConstraint.constant = 5.0f + (15.0f * level);
        
        [self updateConstraintsIfNeeded];
        
        if (level == 0) {
            self.backgroundColor = [UIColor whiteColor];
        }
        else {
            if (level % 2) {
                self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
            }
            else {
                self.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
            }
        }
    }
}

- (void)setCollapsed:(BOOL)collapsed
{
    if (collapsed != _collapsed) {
        _collapsed = collapsed;
        
        self.authorLabel.alpha = collapsed ? 0.5f : 1.0f;
        self.pointsLabel.alpha = collapsed ? 0.5f : 1.0f;
        self.expandCollapseView.alpha = collapsed ? 0.5f : 1.0f;
        
        [self.expandCollapseView setImage:[UIImage imageNamed:collapsed ? @"collapse" : @"expand"]];
    }
}

- (void)configureForComment:(RKComment *)comment level:(NSInteger)level
{
    self.authorLabel.text = comment.author;
    self.bodyLabel.text = comment.body;
    
//    NSString *body = [comment.bodyHTML stringByUnescapingHTMLEntities];
//    body = [body stringByReplacingOccurrencesOfString:@"</p>\n</div>" withString:@"</p>"];
//    body = [body stringByReplacingOccurrencesOfString:@"<div class=\"md\">" withString:@""];
//    NSLog(@"%@", body);
//    
//    NSDictionary *options = @{ NSTextSizeMultiplierDocumentOption: [NSNumber numberWithFloat: 1.0],
//                               DTDefaultFontFamily: [UIFont systemFontOfSize:16.0].familyName, DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
//                               };
//    
//    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *html = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
//    
//    self.bodyLabel.attributedText = html;
    
    NSString *scoreText = @"points";
    if (comment.score == 1) {
        scoreText = @"point";
    }
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%zd %@ • %@", comment.score, scoreText, [comment.created dateTimeAgo]];
    
    self.level = level;
}

@end
