//
//  SubredditImageViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "SubredditImageViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface SubredditImageViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *problemLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIView *nameLabelContainer;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;

@property (nonatomic, weak) IBOutlet UIView *previousButton;
@property (nonatomic, weak) IBOutlet UIView *nextButton;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL visible;

@property (nonatomic, assign) BOOL changedImage;

@end

@implementation SubredditImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nameLabel.text = self.link.title;
    
    [self updateName];
    [self updateContentInsets];
    [self updateName];
    
    if (self.changedImage) {
        self.progressBar.hidden = NO;
        
        self.changedImage = NO;
        
        [self.imageView sd_setImageWithURL:self.link.URL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            self.progressBar.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.progressBar.hidden = YES;
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (error != nil) {
                self.problemLabel.hidden = NO;
                return;
            }
            
            CGRect frame = self.imageView.frame;
            frame.size = image.size;
            self.imageView.frame = frame;
            
            [self updateZoom];
        }];
    }
    else {
        [self centerScrollViewContents];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.visible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.visible = NO;
}

- (void)setShowingBanner:(BOOL)showingBanner
{
    if (showingBanner != _showingBanner) {
        _showingBanner = showingBanner;
        
        if (self.visible) {
            [UIView animateWithDuration:.25f animations:^{
                
            }];
        }
        else {
            [self updateContentInsets];
            [self centerScrollViewContents];
        }
    }
}

- (void)updateContentInsets
{
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    
    contentInset.top += _showingBanner ? 50.0f : 0;
    contentInset.bottom += self.nameLabel.frame.size.height + 20.0f;
    
    if (!self.pageViewController.toolbarsHidden) {
        contentInset.top += 20.0f + self.navigationController.navigationBar.bounds.size.height;
        contentInset.bottom += self.navigationController.toolbar.bounds.size.height;
    }
    
    self.scrollView.contentInset = contentInset;
    self.scrollView.scrollIndicatorInsets = contentInset;
}

- (IBAction)previous:(id)sender
{
    [self.pageViewController setActiveLink:[NSIndexPath indexPathForRow:self.pageIndex - 1 inSection:0] animated:YES];
}

- (IBAction)next:(id)sender
{
    [self.pageViewController setActiveLink:[NSIndexPath indexPathForRow:self.pageIndex + 1 inSection:0] animated:YES];
}

- (void)setLink:(RKLink *)link
{
    if (_link != link) {
        _link = link;
        
        self.changedImage = YES;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (void)updateZoom
{
    self.scrollView.contentSize = self.imageView.image.size;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size.height -= self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)updateName
{
    CGFloat nameMargin = 10;
    CGRect frame = self.nameLabel.frame;
    frame.origin.x = nameMargin;
    frame.origin.y = nameMargin;
    frame.size = [self.nameLabel sizeThatFits:CGSizeMake(self.nameLabelContainer.bounds.size.width - (nameMargin * 2), self.view.bounds.size.height / 2)];
    frame.size.width = self.nameLabelContainer.bounds.size.width - (nameMargin * 2);
    
    CGRect containerFrame = self.nameLabelContainer.frame;
    containerFrame.size.height = frame.size.height + (nameMargin * 2) + 200;
    containerFrame.origin.y = self.view.bounds.size.height - self.scrollView.contentInset.bottom;
    
//    if (self.showingBanner) {
//        containerFrame.origin.y -= self.bannerView.frame.size.height;
//    }
    
    self.nameLabelContainer.frame = containerFrame;
    
    self.nameLabel.frame = frame;
    
    [self.nameLabel.superview bringSubviewToFront:self.nameLabel];
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    boundsSize.height -= self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
    
    [self updateName];
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (self.animating) {
        return;
    }

    self.animating = YES;
    self.pageViewController.toolbarsHidden = !self.pageViewController.toolbarsHidden;
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.pageViewController.toolbarsHidden withAnimation:UIStatusBarAnimationSlide];
    
    if (self.delegate) {
        if (self.pageViewController.toolbarsHidden) {
            [self.delegate subredditImageViewControllerWillHideToolbars:self];
        }
        else {
            [self.delegate subredditImageViewControllerWillShowToolbars:self];
        }
    }
    
    [UIView animateWithDuration:.25f animations:^{
        [self.navigationController.toolbar setAlpha:!self.pageViewController.toolbarsHidden ? 1 : 0];
        [self.navigationController.navigationBar setAlpha:!self.pageViewController.toolbarsHidden ? 1 : 0];
        
        [self updateContentInsets];
        
        [self centerScrollViewContents];
    } completion:^(BOOL finished) {
        self.animating = NO;
        
        [self.scrollView flashScrollIndicators];
    }];
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    CGPoint pointInView = [gesture locationInView:self.imageView];
    
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGFloat newZoomScale = self.scrollView.zoomScale * 4.0f;
        newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = pointInView.x - (w / 2.0f);
        CGFloat y = pointInView.y - (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        
        [self.scrollView zoomToRect:rectToZoomTo animated:YES];
        [self.scrollView flashScrollIndicators];
    }
    else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
