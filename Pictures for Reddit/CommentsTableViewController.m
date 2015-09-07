//
//  CommentsTableViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "CommentsTableViewController.h"

#import "NSDate+TimeAgo.h"

#import "CommentTableViewCell.h"

@interface CommentsTableViewController ()

@property (nonatomic, strong) NSArray *rootComments;
@property (nonatomic, strong) NSArray *comments;

@property (nonatomic, strong) NSMutableArray *collapsedComments;
@property (nonatomic, strong) NSMutableArray *expandedComments;
@property (nonatomic, strong) NSMutableDictionary *indentationLevels;

@end

@implementation CommentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collapsedComments = [NSMutableArray array];
    self.expandedComments = [NSMutableArray array];
    self.indentationLevels = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.link != nil) {
        [[RKClient sharedClient] commentsForLink:self.link completion:^(NSArray *collection, NSError *error) {
            self.rootComments = collection;
            self.comments = self.rootComments;
            
            [self.tableView reloadData];
        }];
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
        [self.delegate commentsTableViewControllerClose:self];
    }
}

- (void)expandRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    [self.expandedComments addObject:comment.identifier];
    
    NSArray *replies = comment.replies;
    NSMutableArray *newComments = [NSMutableArray arrayWithArray:self.comments];
    
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    NSInteger startingIndex = indexPath.row + 1;
    
    NSInteger indentationLevel = 1;
    if ([self.indentationLevels objectForKey:comment.identifier]) {
        indentationLevel = [[self.indentationLevels objectForKey:comment.identifier] integerValue] + 1;
    }
    
    for (int i = 0; i < replies.count; i++) {
        [indexes addIndex:startingIndex + i];
        
        RKComment *reply = [replies objectAtIndex:i];
        [self.indentationLevels setObject:@(indentationLevel) forKey:reply.identifier];
    }
    
    [newComments insertObjects:replies atIndexes:indexes];
    
    self.comments = [NSArray arrayWithArray:newComments];
    [self.tableView reloadData];
    
//    CommentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.collapsed = NO;
}

- (void)collapseRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    [self.expandedComments removeObject:comment.identifier];
    
    NSArray *replies = comment.replies;
    NSMutableArray *newComments = [NSMutableArray arrayWithArray:self.comments];
    
    for (int i = 0; i < replies.count; i++) {
        RKComment *reply = [replies objectAtIndex:i];
        [self.indentationLevels removeObjectForKey:reply.identifier];
    }
    
    [newComments removeObjectsInArray:replies];
    
    [self.collapsedComments addObject:comment.identifier];
    
    self.comments = [NSArray arrayWithArray:newComments];
    [self.tableView reloadData];
    
//    CommentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.collapsed = YES;
}

- (void)expandCollapse:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    CommentTableViewCell *cell = (CommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        return;
    }
    
    RKComment *comment = [self.comments objectAtIndex:indexPath.row];
    if ([self.expandedComments containsObject:comment.identifier]) {
        [self collapseRowAtIndexPath:indexPath];
        [button setTitle:@"+" forState:UIControlStateNormal];
    }
    else if (comment.replies.count > 0) {
        [self expandRowAtIndexPath:indexPath];
        [button setTitle:@"-" forState:UIControlStateNormal];
    }
    else {
        [self collapseRowAtIndexPath:indexPath];
        [button setTitle:@"+" forState:UIControlStateNormal];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    RKComment *comment = [self.comments objectAtIndex:indexPath.row];
//    cell.authorLabel.text = comment.author;
//    cell.bodyLabel.attributedString = comment.body;
//    
//    NSString *scoreText = @"points";
//    if (comment.score == 1) {
//        scoreText = @"point";
//    }
//    
//    cell.pointsLabel.text = [NSString stringWithFormat:@"%zd %@ • %@", comment.score, scoreText, [comment.created dateTimeAgo]];
    
//    cell.expandCollapseButton.tag = indexPath.row;
    
    
//    [cell.expandCollapseButton addTarget:self action:@selector(expandCollapse:) forControlEvents:UIControlEventTouchUpInside];
    
//    if (comment.replies.count > 0) {
//        [cell.expandCollapseButton setTitle:@"+" forState:UIControlStateNormal];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    if ([self.indentationLevels objectForKey:comment.identifier]) {
        return [[self.indentationLevels objectForKey:comment.identifier] integerValue];
    }
    
    return 0;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CommentTableViewCell *commentCell = (CommentTableViewCell *)cell;
//    
//    if (!commentCell.expandCollapseButton.hidden) {
//        
//    }
//}

@end
