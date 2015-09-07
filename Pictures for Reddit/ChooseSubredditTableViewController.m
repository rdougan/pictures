//
//  ChooseSubredditTableViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "ChooseSubredditTableViewController.h"

#import "SubredditTableViewCell.h"

@interface ChooseSubredditTableViewController ()

@property (nonatomic, strong) NSArray *subreddits;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSURLSessionDataTask *searchTask;

@end

@implementation ChooseSubredditTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SubredditTableViewCell" bundle:nil] forCellReuseIdentifier:@"SubredditCell"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = @"Enter subreddit name";
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    RKPagination *pagination = [RKPagination paginationWithLimit:50];
    
    [[RKClient sharedClient] popularSubredditsWithPagination:pagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        self.subreddits = collection;
    }];
}

- (void)setSubreddits:(NSArray *)subreddits
{
    if ([self.delegate respondsToSelector:@selector(chooseSubreddit:canAddSubreddit:)]) {
        NSMutableArray *filtered = [NSMutableArray array];
        
        [subreddits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RKSubreddit *subreddit = obj;
            
            if ([self.delegate chooseSubreddit:self canAddSubreddit:subreddit]) {
                [filtered addObject:subreddit];
            }
        }];
        
        subreddits = filtered;
    }
    
    _subreddits = subreddits;
    
    [self.tableView reloadData];
}

- (void)setSearchResults:(NSArray *)searchResults
{
    if ([self.delegate respondsToSelector:@selector(chooseSubreddit:canAddSubreddit:)]) {
        NSMutableArray *filtered = [NSMutableArray array];
        
        [searchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RKSubreddit *subreddit = obj;
            
            if ([self.delegate chooseSubreddit:self canAddSubreddit:subreddit]) {
                [filtered addObject:subreddit];
            }
        }];
        
        searchResults = filtered;
    }
    
    _searchResults = searchResults;
    
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    if (self.searchTask != nil) {
        [self.searchTask cancel];
    }
    
    if (searchText == nil || [searchText isEqualToString:@""]) {
        self.searchResults = [NSArray arrayWithArray:self.subreddits];
        return;
    }
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResults = [self.subreddits filteredArrayUsingPredicate:resultPredicate];
    
    if (searchText.length > 2) {
        RKPagination *pagination = [RKPagination paginationWithLimit:50];
        self.searchTask = [[RKClient sharedClient] searchForSubredditsByName:searchText pagination:pagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
            if (error == nil) {
                self.searchResults = [collection arrayByAddingObjectsFromArray:self.searchResults];
            }
        }];
    }
}

- (IBAction)close:(id)sender
{
    if (self.delegate) {
        [self.delegate chooseSubredditDidCancel:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return [self.searchResults count];
    }
    
    if (self.subreddits != nil) {
        return [self.subreddits count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditTableViewCell *subredditCell = (SubredditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SubredditCell"];
    
    RKSubreddit *subreddit;
    if (self.searchController.active) {
        subreddit = [self.searchResults objectAtIndex:indexPath.row];
    }
    else {
        subreddit = [self.subreddits objectAtIndex:indexPath.row];
    }
    
    [subredditCell configureWithSubreddit:subreddit];
    
    return subredditCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate != nil) {
        RKSubreddit *subreddit;
        
        if (self.searchController.active) {
            subreddit = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            subreddit = [self.subreddits objectAtIndex:indexPath.row];
        }
        
        [self.delegate chooseSubreddit:self didSelectSubreddit:subreddit];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
}

@end
