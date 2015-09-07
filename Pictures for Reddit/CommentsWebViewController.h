//
//  CommentsWebViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsWebViewController;

@protocol CommentsWebViewControllerDelegate <NSObject>

@optional
- (void)commentsWebViewControllerClose:(CommentsWebViewController *)viewController;

@end

@interface CommentsWebViewController : UIViewController

@property (nonatomic, weak) id <CommentsWebViewControllerDelegate> delegate;

@property (nonatomic, strong) NSURL *url;

@end
