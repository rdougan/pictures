//
//  SubredditListTableViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "SubredditListTableViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"

#import "Helper.h"
#import "UIImage+Resize.h"
#import "LoadingTableViewCell.h"
#import "LinkTableViewCell.h"

@interface SubredditListTableViewController ()

@property (nonatomic, strong) NSArray *links;

@property (nonatomic, strong) UIView *segmentedControlView;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) RKPagination *pagination;
@property (nonatomic, assign) BOOL loadingMore;
@property (nonatomic, assign) BOOL reachedEnd;

@property (nonatomic, assign) BOOL stopAllRequests;

@property (nonatomic, assign) RKSubredditCategory category;
@property (nonatomic, assign) RKTimeSortingMethod timeSorting;

@end

@implementation SubredditListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stopAllRequests = NO;
    
    self.category = RKSubredditCategoryHot;
    
    [self.tableView addSubview:self.emptyLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.stopAllRequests = NO;
    
    if (self.loadingMore) {
        self.loadingMore = NO;
        
        [self loadMore:self];
    }
    else if (self.links.count == 0) {
        [self loadWithCallback:nil];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.stopAllRequests = YES;
}

- (void)deselectRows
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setSubreddit:(RKSubreddit *)subreddit
{
    _subreddit = subreddit;
    
    self.links = [NSArray array];
    
    if (subreddit != nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.attributedText = [Helper attributedTitleForSubreddit:subreddit];;
        
        [titleLabel sizeToFit];
        
        self.title = nil;
        self.navigationItem.titleView = titleLabel;
        
        self.pagination = [RKPagination paginationWithLimit:50];
    }
}

- (void)setLinks:(NSArray *)links
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAllLinks"]) {
        NSMutableArray *imageLinks = [NSMutableArray array];
        
        [links enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RKLink *link = obj;
            if (link.isImageLink) {
                [imageLinks addObject:link];
            }
        }];
        
        links = imageLinks;
    }
    
    _links = links;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setCategory:(RKSubredditCategory)category
{
    if (category != _category) {
        _category = category;
        
        self.links = [NSArray array];
        
        self.pagination = [RKPagination paginationWithLimit:50];
    }
}

- (void)setTimeSorting:(RKTimeSortingMethod)timeSorting
{
    if (timeSorting != _timeSorting) {
        _timeSorting = timeSorting;
        
        self.links = [NSArray array];
        
        self.pagination = [RKPagination paginationWithLimit:50];
        self.pagination.timeMethod = timeSorting;
    }
}

- (UILabel *)emptyLabel
{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        _emptyLabel.hidden = YES;
        _emptyLabel.font = [UIFont systemFontOfSize:13.0];
        _emptyLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.text = @"No pictures to display";
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAllLinks"]) {
            _emptyLabel.text = @"No links to display";
        }
    }
    
    return _emptyLabel;
}

- (void)loadWithCallback:(void (^)(NSArray *links))callback
{
    self.emptyLabel.hidden = YES;
    
    if (self.loadingMore) {
        return;
    }
    
    if (self.stopAllRequests) {
        return;
    }
    
    NSLog(@"load");
    
    self.emptyLabel.hidden = YES;
    self.loadingMore = YES;
    self.reachedEnd = NO;
    
    [[RKClient sharedClient] linksInSubreddit:self.subreddit category:self.category pagination:self.pagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        if (self.stopAllRequests) {
            return;
        }
        
        self.pagination = pagination;
        self.loadingMore = NO;
        
        self.links = collection;
        
        if (self.links.count == 0) {
            if (self.pagination.after != nil) {
                [self loadMore:self];
            }
            else {
                self.emptyLabel.hidden = NO;
            }
        }
        
        if (callback != nil) {
            callback(self.links);
        }
    }];
}

- (IBAction)loadMore:(id)sender
{
    if (self.loadingMore) {
        return;
    }
    
    if (self.stopAllRequests) {
        return;
    }
    
    if (self.reachedEnd) {
        return;
    }
    
    NSLog(@"loadMore");
    
    self.emptyLabel.hidden = YES;
    self.loadingMore = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    RKPagination *pagination = [RKPagination paginationWithLimit:50];
    pagination.after = self.pagination.after;
    
    [[RKClient sharedClient] linksInSubreddit:self.subreddit category:self.category pagination:pagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        if (self.stopAllRequests) {
            return;
        }
        
        self.links = [self.links arrayByAddingObjectsFromArray:collection];
        
        self.pagination = pagination;
        
        if (self.links.count == 0) {
            self.loadingMore = NO;
            
            if (self.pagination.after != nil) {
                [self loadMore:self];
            }
            else {
                self.emptyLabel.hidden = NO;
            }
        }
        else {
            if (self.pagination == nil) {
                self.reachedEnd = YES;
            }
            
            self.loadingMore = NO;
        }
    }];
}

- (IBAction)didRefresh:(id)sender
{
    self.pagination = [RKPagination paginationWithLimit:50];
    
    [self loadWithCallback:^(NSArray *links) {
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)segmentedControlDidChange:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 1:
            self.category = RKSubredditCategoryNew;
            break;
            
        case 2:
            self.category = RKSubredditCategoryTop;
            break;
            
        default:
            self.category = RKSubredditCategoryHot;
            break;
    }
    
    [self loadWithCallback:nil];
}

- (IBAction)segmentedControlLengthDidChange:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    self.timeSorting = segmentedControl.selectedSegmentIndex + 1;
    
    [self loadWithCallback:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.links != nil) {
        NSInteger count = [self.links count];
        if (self.loadingMore && !self.reachedEnd) {
            count += 1;
        }
        
        return count;
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
    if (self.loadingMore && !self.reachedEnd && indexPath.row == count - 1) {
        return NO;
    }
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
    if (self.loadingMore && !self.reachedEnd && indexPath.row == count - 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
    }
    else {
        LinkTableViewCell *linkCell = (LinkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        RKLink *link = [self.links objectAtIndex:indexPath.row];
        [linkCell configureForLink:link];
        
        cell = linkCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[LinkTableViewCell class]]) {
        LinkTableViewCell *linkCell = (LinkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        [linkCell.thumbnailImageView sd_cancelCurrentImageLoad];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell.reuseIdentifier isEqualToString:@"LoadingCell"]) {
        LoadingTableViewCell *loadingCell = (LoadingTableViewCell *)cell;
        
        if (![loadingCell.loadingIndicator isAnimating]) {
            [loadingCell.loadingIndicator startAnimating];
        }
    }
    
    NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
    if (count > 0 && indexPath.row > (count - 5)) {
        [self loadMore:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80.0f;
    }
    
    return [tableView rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self tableView:tableView numberOfRowsInSection:0];
    if (self.loadingMore && !self.reachedEnd && indexPath.row == count - 1) {
        return;
    }
    
    SubredditSwipeViewController *vc = [[UIStoryboard storyboardWithName:@"SwipeView" bundle:nil] instantiateViewControllerWithIdentifier:@"SubredditSwipeViewController"];
    vc.linksDelegate = self;
    [vc setActiveLink:indexPath animated:NO];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (!self.segmentedControlView) {
            CGFloat margin = 6;
            
            self.segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.tableView.bounds.size.width, 44)];
            self.segmentedControlView.clipsToBounds = YES;
            self.segmentedControlView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            
            UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"hot", @"new", @"top"]];
            [control setFrame:CGRectMake(margin, margin, self.tableView.bounds.size.width - (margin * 2), 44 - (margin * 2))];
            [control setBackgroundColor:[UIColor whiteColor]];
            [control setSelectedSegmentIndex:0];
            [control setEnabled:YES];
            [control addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
            
            [self.segmentedControlView addSubview:control];
            
            control = [[UISegmentedControl alloc] initWithItems:@[@"hour", @"day", @"week", @"month", @"year", @"all"]];
            [control setFrame:CGRectMake(margin, 44, self.tableView.bounds.size.width - (margin * 2), 44 - (margin * 2))];
            [control setBackgroundColor:[UIColor whiteColor]];
            [control setSelectedSegmentIndex:0];
            [control setEnabled:YES];
            [control addTarget:self action:@selector(segmentedControlLengthDidChange:) forControlEvents:UIControlEventValueChanged];
            
            [self.segmentedControlView addSubview:control];
        }
        
        return self.segmentedControlView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.category == RKSubredditCategoryTop ? 84.0f : 44.0f;
    }
    
    return 0.f;
}

#pragma mark - SubredditSwipeViewControllerDelegate

- (NSArray *)subredditSwipeViewLinks
{
    return self.links;
}

- (void)subredditSwipeViewDidViewLink:(RKLink *)link
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.links indexOfObject:link] inSection:0];
    NSInteger count = [self tableView:self.tableView numberOfRowsInSection:0];
    
    if (indexPath.row > (count - 5)) {
        self.stopAllRequests = NO;
        self.loadingMore = NO;
        [self loadMore:nil];
    }
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

@end
