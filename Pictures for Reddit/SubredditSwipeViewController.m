//
//  SubredditSwipeViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "SubredditSwipeViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "SubredditImageViewController.h"

@interface SubredditSwipeViewController () <SubredditImageViewControllerDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, assign) BOOL showingBanner;

@property (nonatomic, strong) UIBarButtonItem *upButton;
@property (nonatomic, strong) UIBarButtonItem *downButton;
@property (nonatomic, strong) UIBarButtonItem *commentsButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;

@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UIButton *commentsView;

@property (nonatomic, strong) NSIndexPath *activeIndexPath;

@end

@implementation SubredditSwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.delegate = self;
    self.dataSource = self;
    
    self.upButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thumbs-up"] style:UIBarButtonItemStylePlain target:self action:@selector(thumbsUp:)];
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.downButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thumbs-down"] style:UIBarButtonItemStylePlain target:self action:@selector(thumbsDown:)];
    
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.commentsLabel = [[UILabel alloc] init];
    self.commentsLabel.font = [UIFont systemFontOfSize:10.0];
    self.commentsLabel.text = @"100";
    self.commentsLabel.textColor = [UIColor whiteColor];
    self.commentsLabel.textAlignment = NSTextAlignmentCenter;
    [self.commentsLabel sizeToFit];
    
    self.commentsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120.0f, 30.0f)];
    [self.commentsView setBackgroundImage:[[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] stretchableImageWithLeftCapWidth:4.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [self.commentsView addSubview:self.commentsLabel];
    
    CGRect commentsLabelFrame = self.commentsView.frame;
    commentsLabelFrame.origin.y = -3.0f;
    self.commentsLabel.frame = commentsLabelFrame;
    
    self.commentsButton = [[UIBarButtonItem alloc] initWithCustomView:self.commentsView];
    
    [self.commentsView addTarget:self action:@selector(showComments:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *space3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareLink:)];
    
    self.toolbarItems = @[
                          self.upButton,
                          space1,
                          self.downButton,
                          space2,
                          self.commentsButton,
                          space3,
                          self.shareButton
                          ];
    
    [self updateToolbarButtons:[self activeLink]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barTintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    self.navigationController.toolbar.tintColor = [UIColor colorWithWhite:1.0 alpha:.7f];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:1.0 alpha:.7f];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self performSelector:@selector(showBannerView) withObject:nil afterDelay:1.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (GADBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 320.0f) / 2, -50.0f, 320.0f, 50.0f)];
        _bannerView.adUnitID = @"ca-app-pub-8313236731327663/3472075230";
        _bannerView.rootViewController = self;
        _bannerView.delegate = self;
        _bannerView.hidden = YES;
        
        [self.view addSubview:_bannerView];
    }
    
    return _bannerView;
}

- (void)showBannerView
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[
                            kGADSimulatorID,
                            @"761dc15c0109dbe35af95a58cd72dda635608020"
                            ];
    [self.bannerView loadRequest:request];
}

- (void)updateBannerView
{
    self.bannerView.hidden = NO;
    
    CGRect bannerFrame = self.bannerView.frame;
    bannerFrame.origin.y = self.toolbarsHidden ? 0 : 20 + self.navigationController.navigationBar.frame.size.height;
    self.bannerView.frame = bannerFrame;
}

- (void)setActiveLink:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    SubredditImageViewController *vc = (SubredditImageViewController *)[self viewControllerAtIndex:indexPath.row];
    if (vc == nil) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (indexPath.row < self.activeIndexPath.row) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    [self setViewControllers:@[vc] direction:direction animated:animated completion:nil];
    
    [self updateToolbarButtons:[[self links] objectAtIndex:indexPath.row]];
    
    self.activeIndexPath = indexPath;
    
    if (vc != nil) {
        [self.linksDelegate subredditSwipeViewDidViewLink:vc.link];
    }
}

- (NSArray *)links
{
    return [self.linksDelegate subredditSwipeViewLinks];
}

- (RKLink *)activeLink
{
    return [[self links] objectAtIndex:self.activeIndexPath.row];
}

- (void)updateToolbarButtons:(RKLink *)link
{
    BOOL signedIn = [RKClient sharedClient].isSignedIn;
    
    self.upButton.enabled = signedIn;
    self.downButton.enabled = signedIn;
    
    [self.upButton setImage:[UIImage imageNamed:@"thumbs-up"]];
    [self.downButton setImage:[UIImage imageNamed:@"thumbs-down"]];
    
    if (link.upvoted) {
        [self.upButton setImage:[UIImage imageNamed:@"thumbs-up-filled"]];
    }
    else if (link.downvoted) {
        [self.downButton setImage:[UIImage imageNamed:@"thumbs-down-filled"]];
    }
    
    self.commentsLabel.text = [NSString stringWithFormat:@"%zd", link.totalComments];
    [self.commentsLabel sizeToFit];
    
    CGRect frame = self.commentsView.frame;
    frame.size.width = fmaxf(self.commentsLabel.frame.size.width + 14.0f, 30.0f);
    frame.origin.x = (self.commentsView.frame.size.width - frame.size.width) / 2;
    self.commentsView.frame = frame;
    
    CGRect commentsLabelFrame = self.commentsView.bounds;
    commentsLabelFrame.origin.y = -3.0f;
    self.commentsLabel.frame = commentsLabelFrame;
}

- (IBAction)thumbsUp:(id)sender
{
    self.upButton.enabled = NO;

    if ([self activeLink].upvoted) {
        [[RKClient sharedClient] revokeVote:[self activeLink] completion:^(NSError *error) {
            self.upButton.enabled = YES;
            
            if (!error) {
                [self.upButton setImage:[UIImage imageNamed:@"thumbs-up"]];
                [self.downButton setImage:[UIImage imageNamed:@"thumbs-down"]];
            }
        }];
    }
    else {
        [[RKClient sharedClient] upvote:[self activeLink] completion:^(NSError *error) {
            self.upButton.enabled = YES;
            
            if (!error) {
                [self.upButton setImage:[UIImage imageNamed:@"thumbs-up-filled"]];
                [self.downButton setImage:[UIImage imageNamed:@"thumbs-down"]];
            }
        }];
    }
}

- (IBAction)thumbsDown:(id)sender
{
    self.downButton.enabled = NO;
    
    if ([self activeLink].downvoted) {
        [[RKClient sharedClient] revokeVote:[self activeLink] completion:^(NSError *error) {
            self.downButton.enabled = YES;
            
            if (!error) {
                [self.upButton setImage:[UIImage imageNamed:@"thumbs-up"]];
                [self.downButton setImage:[UIImage imageNamed:@"thumbs-down"]];
            }
        }];
    }
    else {
        [[RKClient sharedClient] downvote:[self activeLink] completion:^(NSError *error) {
            self.downButton.enabled = YES;
            
            if (!error) {
                [self.upButton setImage:[UIImage imageNamed:@"thumbs-up"]];
                [self.downButton setImage:[UIImage imageNamed:@"thumbs-down-filled"]];
            }
        }];
    }
}

- (IBAction)showComments:(id)sender
{
    UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsNavigationController"];
    
    RKLink *link = [self activeLink];
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://reddit.com/r/%@/comments/%@", link.subreddit, link.identifier]];
//    
//    CommentsWebViewController *vc = (CommentsWebViewController *)nvc.topViewController;
//    vc.url = url;
//    vc.delegate = self;
    
//    CommentsTableViewController *vc = (CommentsTableViewController *)nvc.topViewController;
//    vc.link = link;
//    vc.delegate = self;
    
    CommentsTreeViewController *vc = (CommentsTreeViewController *)nvc.topViewController;
    vc.link = link;
    vc.delegate = self;
    
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)shareLink:(id)sender
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[self activeLink].URL options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        vc.excludedActivityTypes = @[UIActivityTypePostToVimeo, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePrint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:vc animated:YES completion:^{
                
            }];
        });
    }];
}

- (SubredditImageViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (([[self links] count] == 0) || (index >= [[self links] count])) {
        return nil;
    }
    
    SubredditImageViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubredditImageViewController"];
    pageContentViewController.pageIndex = index;
    pageContentViewController.showingBanner = self.showingBanner;
    pageContentViewController.delegate = self;
    
    RKLink *link = [[self links] objectAtIndex:index];
    pageContentViewController.link = link;
    pageContentViewController.pageViewController = self;
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SubredditImageViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SubredditImageViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [[self links] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    SubredditImageViewController *vc = [pendingViewControllers firstObject];
    
    if (vc != nil) {
        [self.linksDelegate subredditSwipeViewDidViewLink:vc.link];
        
        [self updateToolbarButtons:vc.link];
        
        self.activeIndexPath = [NSIndexPath indexPathForRow:vc.pageIndex inSection:0];
    }
}

#pragma mark - CommentsTreeViewController

- (void)commentsTreeViewControllerClose:(CommentsTreeViewController *)viewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (!self.showingBanner) {
        self.showingBanner = YES;
        
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
            SubredditImageViewController *vc = (SubredditImageViewController *)obj;
            vc.showingBanner = YES;
        }];

        [UIView animateWithDuration:.25f animations:^{
            [self updateBannerView];
        }];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (self.showingBanner) {
        self.showingBanner = NO;
        
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
            SubredditImageViewController *vc = (SubredditImageViewController *)obj;
            vc.showingBanner = NO;
        }];
        
        [UIView animateWithDuration:.25f animations:^{
            [self updateBannerView];
        }];
    }
}

#pragma mark - SubredditImageViewControllerDelegate

- (void)subredditImageViewControllerWillHideToolbars:(SubredditImageViewController *)viewController
{
    [UIView animateWithDuration:.25f animations:^{
        [self updateBannerView];
    }];
}

- (void)subredditImageViewControllerWillShowToolbars:(SubredditImageViewController *)viewController
{
    [UIView animateWithDuration:.25f animations:^{
        [self updateBannerView];
    }];
}

@end
