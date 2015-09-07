//
//  CommentsWebViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "CommentsWebViewController.h"

@interface CommentsWebViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation CommentsWebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.url != nil) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.delegate = nil;
}

- (IBAction)close:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate commentsWebViewControllerClose:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
